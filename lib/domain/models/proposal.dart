class DissentRecord {
  const DissentRecord({
    required this.voterDid,
    required this.agentName,
    required this.rationale,
    required this.timestamp,
  });

  factory DissentRecord.fromJson(Map<String, dynamic> json) {
    return DissentRecord(
      voterDid: json['voter_did'] as String? ?? '',
      agentName: json['agent_name'] as String? ?? '',
      rationale: json['rationale'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final String voterDid;
  final String agentName;
  final String rationale;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'voter_did': voterDid,
        'agent_name': agentName,
        'rationale': rationale,
        'timestamp': timestamp.toIso8601String(),
      };
}

class Proposal {
  const Proposal({
    required this.id,
    required this.roomId,
    required this.title,
    required this.description,
    required this.proposerDid,
    required this.options,
    required this.votes,
    required this.dissentLogs,
    required this.status,
    required this.createdAt,
    this.closedAt,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    final rawVotes = json['votes'] as Map<String, dynamic>? ?? {};
    final rawDissents = json['dissent_logs'] as List<dynamic>? ?? [];

    return Proposal(
      id: json['id'] as String? ?? '',
      roomId: json['room_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      proposerDid: json['proposer_did'] as String? ?? '',
      options: rawOptions.map((e) => e.toString()).toList(),
      votes: rawVotes.map((k, v) => MapEntry(k, v.toString())),
      dissentLogs: rawDissents
          .map((d) => DissentRecord.fromJson(d as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      closedAt: json['closed_at'] != null
          ? DateTime.tryParse(json['closed_at'] as String)
          : null,
    );
  }

  final String id;
  final String roomId;
  final String title;
  final String description;
  final String proposerDid;
  final List<String> options;
  final Map<String, String> votes;
  final List<DissentRecord> dissentLogs;
  final String status;
  final DateTime createdAt;
  final DateTime? closedAt;

  bool get isOpen => status == 'open';

  Map<String, dynamic> toJson() => {
        'id': id,
        'room_id': roomId,
        'title': title,
        'description': description,
        'proposer_did': proposerDid,
        'options': options,
        'votes': votes,
        'dissent_logs': dissentLogs.map((d) => d.toJson()).toList(),
        'status': status,
        'created_at': createdAt.toIso8601String(),
        if (closedAt != null) 'closed_at': closedAt!.toIso8601String(),
      };
}
