import 'package:flutter_test/flutter_test.dart';
import 'package:acr_flutter/domain/models/agent.dart';
import 'package:acr_flutter/domain/models/audit_entry.dart';
import 'package:acr_flutter/domain/models/buddy_relation.dart';
import 'package:acr_flutter/domain/models/escalation.dart';
import 'package:acr_flutter/domain/models/file_attachment.dart';
import 'package:acr_flutter/domain/models/mcp_tool_call.dart';
import 'package:acr_flutter/domain/models/message.dart';
import 'package:acr_flutter/domain/models/proposal.dart';
import 'package:acr_flutter/domain/models/room.dart';

void main() {
  group('JSON Serialization & Pattern Matching', () {
    test('Agent serializes and deserializes correctly', () {
      final json = {
        'did': 'did:key:z6Mkq5Xv',
        'name': 'Claude Code Reviewer',
        'avatar': 'https://example.com/avatar.png',
        'role': 'agent',
        'status': 'deliberating',
        'org': 'Anthropic Engineering',
        'capabilities': ['chat.*', 'mcp.ast_diff'],
        'verified': true,
        'last_seen': '2026-08-27T10:00:00.000Z',
      };

      final agent = Agent.fromJson(json);
      expect(agent.did, 'did:key:z6Mkq5Xv');
      expect(agent.name, 'Claude Code Reviewer');
      expect(agent.status, AgentStatus.deliberating);
      expect(agent.capabilities, contains('mcp.ast_diff'));

      final outJson = agent.toJson();
      expect(outJson['did'], 'did:key:z6Mkq5Xv');
      expect(outJson['status'], 'deliberating');
    });

    test('Room serializes and deserializes correctly', () {
      final json = {
        'id': 'consensus-main',
        'name': 'Consensus Main',
        'description': 'Deliberation floor',
        'topic': 'W3C DID/VC',
        'is_private': false,
        'participants': ['did:key:1'],
        'created_at': '2026-08-27T10:00:00.000Z',
        'message_count': 5,
      };

      final room = Room.fromJson(json);
      expect(room.id, 'consensus-main');
      expect(room.messageCount, 5);

      final outJson = room.toJson();
      expect(outJson['id'], 'consensus-main');
      expect(outJson['message_count'], 5);
    });

    test('McpToolCall serializes and deserializes correctly', () {
      final json = {
        'id': 'tool-101',
        'tool_name': 'mcp.ast_diff.verify',
        'arguments': '{"target":"hub.go"}',
        'output': 'Invariant verified',
        'status': 'completed',
        'latency_ms': 0.38,
      };

      final toolCall = McpToolCall.fromJson(json);
      expect(toolCall.toolName, 'mcp.ast_diff.verify');
      expect(toolCall.latencyMs, 0.38);
      expect(toolCall.output, 'Invariant verified');

      final outJson = toolCall.toJson();
      expect(outJson['tool_name'], 'mcp.ast_diff.verify');
      expect(outJson['latency_ms'], 0.38);
    });

    test('Message with toolCall serializes correctly', () {
      final json = {
        'id': 'msg-1',
        'room_id': 'consensus-main',
        'sender_did': 'did:key:z6Mkq5Xv',
        'sender': 'Claude',
        'avatar': '',
        'role': 'agent',
        'content': 'Verified AST diff',
        'tool_call': {
          'id': 'tool-1',
          'tool_name': 'mcp.ast_diff',
          'arguments': '{}',
          'status': 'completed',
          'latency_ms': 0.42,
        },
        'timestamp': '2026-08-27T10:00:00.000Z',
      };

      final msg = Message.fromJson(json);
      expect(msg.content, 'Verified AST diff');
      expect(msg.toolCall, isNotNull);
      expect(msg.toolCall!.latencyMs, 0.42);

      final outJson = msg.toJson();
      expect(outJson['id'], 'msg-1');
      expect(outJson['tool_call'], isA<Map<String, dynamic>>());
    });

    test('Escalation serializes and updates properly', () {
      final json = {
        'id': 'esc-1',
        'requesting_did': 'did:key:z6Mkp2x1',
        'agent_name': 'Devin',
        'room_id': 'consensus-main',
        'action': 'k8s.deploy',
        'risk_level': 'HIGH',
        'payload': '{"target":"prod"}',
        'status': 'pending',
        'created_at': '2026-08-27T10:00:00.000Z',
      };

      final esc = Escalation.fromJson(json);
      expect(esc.status, EscalationStatus.pending);
      expect(esc.riskLevel, 'HIGH');

      final approved = esc.copyWith(
        status: EscalationStatus.approved,
        operatorDid: 'did:key:z6Mka881...operator',
        signature: 'ed25519:sig-test',
      );
      expect(approved.status, EscalationStatus.approved);
      expect(approved.operatorDid, isNotNull);
    });

    test('AuditEntry serializes state hash chain correctly', () {
      final json = {
        'index': 4,
        'event_type': 'ESCALATION_APPROVED',
        'agent_did': 'did:key:z6Mka881...operator',
        'room_id': 'consensus-main',
        'payload_summary': 'Operator approved deploy',
        'state_hash': 'abcdef123456',
        'previous_hash': '123456abcdef',
        'timestamp': '2026-08-27T10:00:00.000Z',
      };

      final entry = AuditEntry.fromJson(json);
      expect(entry.index, 4);
      expect(entry.eventType, 'ESCALATION_APPROVED');
      expect(entry.stateHash, 'abcdef123456');

      final outJson = entry.toJson();
      expect(outJson['index'], 4);
      expect(outJson['state_hash'], 'abcdef123456');
    });

    test('BuddyRelation serializes and deserializes correctly', () {
      final json = {
        'from_did': 'did:key:z6Mka881',
        'to_did': 'did:key:z6Mkq5Xv',
        'status': 'accepted',
        'created_at': '2026-08-27T10:00:00.000Z',
      };

      final rel = BuddyRelation.fromJson(json);
      expect(rel.fromDid, 'did:key:z6Mka881');
      expect(rel.status, BuddyStatus.accepted);

      final out = rel.toJson();
      expect(out['status'], 'accepted');
    });

    test('Proposal with DissentRecords serializes and deserializes correctly', () {
      final json = {
        'id': 'prop-101',
        'room_id': 'consensus-main',
        'title': 'CIP-104: AST Invariant Guard',
        'description': 'Proposal to enforce AST hash validation',
        'proposer_did': 'did:key:z6Mka881',
        'options': ['APPROVE', 'REJECT', 'DISSENT'],
        'votes': {'did:key:1': 'APPROVE', 'did:key:2': 'DISSENT'},
        'dissent_logs': [
          {
            'voter_did': 'did:key:2',
            'agent_name': 'Claude',
            'rationale': 'Potential latency regression in AST parsing',
            'timestamp': '2026-08-27T10:00:00.000Z',
          }
        ],
        'status': 'open',
        'created_at': '2026-08-27T10:00:00.000Z',
      };

      final prop = Proposal.fromJson(json);
      expect(prop.id, 'prop-101');
      expect(prop.isOpen, isTrue);
      expect(prop.dissentLogs.length, 1);
      expect(prop.dissentLogs.first.rationale, contains('latency regression'));

      final out = prop.toJson();
      expect(out['status'], 'open');
      expect((out['dissent_logs'] as List).length, 1);
    });

    test('FileAttachment and Message attachment serializes correctly', () {
      final attJson = {
        'id': 'file-99',
        'filename': 'ast_graph.png',
        'size': 204800,
        'mime_type': 'image/png',
        'url': '/api/v1/files/file-99',
      };

      final att = FileAttachment.fromJson(attJson);
      expect(att.isImage, isTrue);
      expect(att.formattedSize, '200.0 KB');

      final msgJson = {
        'id': 'msg-1',
        'room_id': 'consensus-main',
        'sender_did': 'did:key:1',
        'content': 'Attached AST graph',
        'attachment': attJson,
      };

      final msg = Message.fromJson(msgJson);
      expect(msg.attachment, isNotNull);
      expect(msg.attachment!.filename, 'ast_graph.png');

      final out = msg.toJson();
      expect(out['attachment'], isNotNull);
    });
  });
}
