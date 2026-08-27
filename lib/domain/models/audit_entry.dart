class AuditEntry {
  final int index;
  final String eventType;
  final String agentDid;
  final String roomId;
  final String payloadSummary;
  final String stateHash;
  final String previousHash;
  final DateTime timestamp;

  const AuditEntry({
    required this.index,
    required this.eventType,
    required this.agentDid,
    required this.roomId,
    required this.payloadSummary,
    required this.stateHash,
    required this.previousHash,
    required this.timestamp,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'index': num index,
        'event_type': String eventType,
        'state_hash': String stateHash,
      } =>
        AuditEntry(
          index: index.toInt(),
          eventType: eventType,
          agentDid: (json['agent_did'] as String?) ?? '',
          roomId: (json['room_id'] as String?) ?? '',
          payloadSummary: (json['payload_summary'] as String?) ?? '',
          stateHash: stateHash,
          previousHash: (json['previous_hash'] as String?) ?? '0000000000000000000000000000000000000000000000000000000000000000',
          timestamp: json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
              : DateTime.now(),
        ),
      _ => throw FormatException('Invalid JSON for AuditEntry: $json'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'event_type': eventType,
      'agent_did': agentDid,
      'room_id': roomId,
      'payload_summary': payloadSummary,
      'state_hash': stateHash,
      'previous_hash': previousHash,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
