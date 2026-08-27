enum EscalationStatus {
  pending,
  approved,
  rejected;

  static EscalationStatus fromString(String val) {
    return switch (val.toLowerCase()) {
      'approved' => EscalationStatus.approved,
      'rejected' => EscalationStatus.rejected,
      _ => EscalationStatus.pending,
    };
  }

  String toWireString() => name;
}

class Escalation {
  final String id;
  final String requestingDid;
  final String agentName;
  final String roomId;
  final String action;
  final String riskLevel;
  final String payload;
  final EscalationStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? operatorDid;
  final String? signature;

  const Escalation({
    required this.id,
    required this.requestingDid,
    required this.agentName,
    required this.roomId,
    required this.action,
    required this.riskLevel,
    required this.payload,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.operatorDid,
    this.signature,
  });

  factory Escalation.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String id,
        'requesting_did': String requestingDid,
        'action': String action,
      } =>
        Escalation(
          id: id,
          requestingDid: requestingDid,
          agentName: (json['agent_name'] as String?) ?? 'Autonomous Agent',
          roomId: (json['room_id'] as String?) ?? '',
          action: action,
          riskLevel: (json['risk_level'] as String?) ?? 'HIGH',
          payload: (json['payload'] as String?) ?? '{}',
          status: EscalationStatus.fromString((json['status'] as String?) ?? 'pending'),
          createdAt: json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
          resolvedAt: json['resolved_at'] != null
              ? DateTime.tryParse(json['resolved_at'].toString())
              : null,
          operatorDid: json['operator_did'] as String?,
          signature: json['signature'] as String?,
        ),
      _ => throw FormatException('Invalid JSON for Escalation: $json'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesting_did': requestingDid,
      'agent_name': agentName,
      'room_id': roomId,
      'action': action,
      'risk_level': riskLevel,
      'payload': payload,
      'status': status.toWireString(),
      'created_at': createdAt.toIso8601String(),
      if (resolvedAt != null) 'resolved_at': resolvedAt!.toIso8601String(),
      if (operatorDid != null) 'operator_did': operatorDid,
      if (signature != null) 'signature': signature,
    };
  }

  Escalation copyWith({
    String? id,
    String? requestingDid,
    String? agentName,
    String? roomId,
    String? action,
    String? riskLevel,
    String? payload,
    EscalationStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? operatorDid,
    String? signature,
  }) {
    return Escalation(
      id: id ?? this.id,
      requestingDid: requestingDid ?? this.requestingDid,
      agentName: agentName ?? this.agentName,
      roomId: roomId ?? this.roomId,
      action: action ?? this.action,
      riskLevel: riskLevel ?? this.riskLevel,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      operatorDid: operatorDid ?? this.operatorDid,
      signature: signature ?? this.signature,
    );
  }
}
