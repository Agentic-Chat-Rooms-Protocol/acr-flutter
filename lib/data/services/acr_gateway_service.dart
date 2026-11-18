import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/agent.dart';
import '../../domain/models/audit_entry.dart';
import '../../domain/models/buddy_relation.dart';
import '../../domain/models/escalation.dart';
import '../../domain/models/file_attachment.dart';
import '../../domain/models/message.dart';
import '../../domain/models/proposal.dart';
import '../../domain/models/room.dart';
import 'daemon_config_stub.dart' if (dart.library.io) 'daemon_config_io.dart';

class AcrGatewayService {
  AcrGatewayService({
    String? baseUrl,
    String? apiToken,
    http.Client? client,
    Map<String, String>? environment,
    String? homeDirectory,
  }) : baseUrl =
           _normalizeBaseUrl(baseUrl) ??
           resolveDefaultDaemonUrl(environment: environment),
       apiToken =
           _normalizeToken(apiToken) ??
           resolveDaemonApiToken(
             environment: environment,
             homeDirectory: homeDirectory,
           ),
       _client = client ?? http.Client();

  final String baseUrl;
  final String? apiToken;
  final http.Client _client;

  static String? _normalizeBaseUrl(String? url) {
    var trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    while (trimmed!.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _normalizeToken(String? token) {
    final trimmed = token?.trim();
    return (trimmed != null && trimmed.isNotEmpty) ? trimmed : null;
  }

  Map<String, String> _headers({bool jsonContent = false}) {
    return {
      if (jsonContent) 'Content-Type': 'application/json',
      if (apiToken != null && apiToken!.isNotEmpty)
        'Authorization': 'Bearer $apiToken',
    };
  }

  // ===== ROOMS =====

  Future<List<Room>> fetchRooms() async {
    final res = await _client.get(
      Uri.parse('$baseUrl/api/v1/rooms'),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch rooms: HTTP ${res.statusCode}');
    }
    final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((item) => Room.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Room> createRoom({
    required String name,
    required String description,
    required String topic,
    required bool isPrivate,
    required String creatorDid,
  }) async {
    final res = await _client.post(
      Uri.parse(
        '$baseUrl/api/v1/rooms?creator_did=${Uri.encodeComponent(creatorDid)}',
      ),
      headers: _headers(jsonContent: true),
      body: jsonEncode({
        'name': name,
        'description': description,
        'topic': topic,
        'is_private': isPrivate,
      }),
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to create room: HTTP ${res.statusCode}');
    }
    return Room.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ===== MESSAGES =====

  Future<List<Message>> fetchMessages(String roomId, {int limit = 50}) async {
    final encodedRoom = Uri.encodeComponent(roomId);
    final res = await _client.get(
      Uri.parse('$baseUrl/api/v1/rooms/$encodedRoom/messages?limit=$limit'),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception(
        'Failed to fetch messages for room $roomId: HTTP ${res.statusCode}',
      );
    }
    final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((item) => Message.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Message> sendMessage({
    required String roomId,
    required String senderDid,
    required String content,
    FileAttachment? attachment,
  }) async {
    final encodedRoom = Uri.encodeComponent(roomId);
    final res = await _client.post(
      Uri.parse('$baseUrl/api/v1/rooms/$encodedRoom/messages'),
      headers: _headers(jsonContent: true),
      body: jsonEncode({
        'sender_did': senderDid,
        'content': content,
        if (attachment != null) 'attachment': attachment.toJson(),
      }),
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to post message: HTTP ${res.statusCode}');
    }
    return Message.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ===== AGENTS =====

  Future<List<Agent>> fetchAgents() async {
    final res = await _client.get(
      Uri.parse('$baseUrl/api/v1/agents'),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch agents: HTTP ${res.statusCode}');
    }
    final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((item) => Agent.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ===== BUDDY SYSTEM (GAP-02) =====

  Future<List<BuddyRelation>> fetchBuddies(String did) async {
    final res = await _client.get(
      Uri.parse('$baseUrl/api/v1/buddies?did=${Uri.encodeComponent(did)}'),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch buddies: HTTP ${res.statusCode}');
    }
    final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((item) => BuddyRelation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> requestBuddy(String fromDid, String toDid) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/api/v1/buddies/request'),
      headers: _headers(jsonContent: true),
      body: jsonEncode({'from_did': fromDid, 'to_did': toDid}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to request buddy: HTTP ${res.statusCode}');
    }
  }

  Future<void> acceptBuddy(String fromDid, String toDid) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/api/v1/buddies/accept'),
      headers: _headers(jsonContent: true),
      body: jsonEncode({'from_did': fromDid, 'to_did': toDid}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to accept buddy: HTTP ${res.statusCode}');
    }
  }

  Future<void> blockBuddy(String fromDid, String toDid) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/api/v1/buddies/block'),
      headers: _headers(jsonContent: true),
      body: jsonEncode({'from_did': fromDid, 'to_did': toDid}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to block buddy: HTTP ${res.statusCode}');
    }
  }

  // ===== PROPOSALS & VOTING (GAP-08) =====

  Future<List<Proposal>> fetchProposals(String roomId) async {
    final res = await _client.get(
      Uri.parse(
        '$baseUrl/api/v1/proposals?room_id=${Uri.encodeComponent(roomId)}',
      ),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch proposals: HTTP ${res.statusCode}');
    }
    final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((item) => Proposal.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Proposal> createProposal({
    required String roomId,
    required String title,
    required String description,
    required String proposerDid,
    List<String>? options,
  }) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/api/v1/proposals'),
      headers: _headers(jsonContent: true),
      body: jsonEncode({
        'room_id': roomId,
        'title': title,
        'description': description,
        'proposer_did': proposerDid,
        'options': options ?? ['APPROVE', 'REJECT', 'DISSENT'],
      }),
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to create proposal: HTTP ${res.statusCode}');
    }
    return Proposal.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Proposal> castVote({
    required String proposalId,
    required String voterDid,
    required String choice,
    String? rationale,
  }) async {
    final encodedProposal = Uri.encodeComponent(proposalId);
    final res = await _client.post(
      Uri.parse('$baseUrl/api/v1/proposals/$encodedProposal/vote'),
      headers: _headers(jsonContent: true),
      body: jsonEncode({
        'voter_did': voterDid,
        'choice': choice,
        'rationale': ?rationale,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to cast vote: HTTP ${res.statusCode}');
    }
    return Proposal.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Proposal> closeProposal({
    required String proposalId,
    required String closerDid,
  }) async {
    final encodedProposal = Uri.encodeComponent(proposalId);
    final res = await _client.post(
      Uri.parse('$baseUrl/api/v1/proposals/$encodedProposal/close'),
      headers: _headers(jsonContent: true),
      body: jsonEncode({'closer_did': closerDid}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to close proposal: HTTP ${res.statusCode}');
    }
    return Proposal.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ===== ESCALATIONS & AUDIT =====

  Future<List<Escalation>> fetchEscalations() async {
    final res = await _client.get(
      Uri.parse('$baseUrl/api/v1/escalations'),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch escalations: HTTP ${res.statusCode}');
    }
    final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((item) => Escalation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Escalation> resolveEscalation({
    required String escalationId,
    required bool approve,
    required String operatorDid,
    required String signature,
  }) async {
    final encodedEsc = Uri.encodeComponent(escalationId);
    final res = await _client.post(
      Uri.parse('$baseUrl/api/v1/escalations/$encodedEsc/resolve'),
      headers: _headers(jsonContent: true),
      body: jsonEncode({
        'approve': approve,
        'operator_did': operatorDid,
        'signature': signature,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception(
        'Failed to resolve escalation $escalationId: HTTP ${res.statusCode}',
      );
    }
    return Escalation.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<AuditEntry>> fetchAuditLogs() async {
    final res = await _client.get(
      Uri.parse('$baseUrl/api/v1/audit'),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch audit logs: HTTP ${res.statusCode}');
    }
    final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((item) => AuditEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
