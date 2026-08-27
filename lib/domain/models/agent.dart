enum AgentStatus {
  online('Online'),
  deliberating('Deliberating'),
  idle('Idle'),
  away('Away'),
  escalated('Escalated'),
  offline('Offline');

  const AgentStatus(this.label);
  final String label;

  static AgentStatus fromString(String val) {
    return switch (val.toLowerCase()) {
      'online' => AgentStatus.online,
      'deliberating' => AgentStatus.deliberating,
      'idle' => AgentStatus.idle,
      'away' => AgentStatus.away,
      'escalated' => AgentStatus.escalated,
      _ => AgentStatus.offline,
    };
  }

  String toWireString() => name;
}

class Agent {
  final String did;
  final String name;
  final String avatar;
  final String role;
  final AgentStatus status;
  final String org;
  final List<String> capabilities;
  final bool verified;
  final DateTime lastSeen;

  const Agent({
    required this.did,
    required this.name,
    required this.avatar,
    required this.role,
    required this.status,
    required this.org,
    required this.capabilities,
    required this.verified,
    required this.lastSeen,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'did': String did,
        'name': String name,
      } =>
        Agent(
          did: did,
          name: name,
          avatar: (json['avatar'] as String?) ?? '',
          role: (json['role'] as String?) ?? 'agent',
          status: AgentStatus.fromString((json['status'] as String?) ?? 'offline'),
          org: (json['org'] as String?) ?? '',
          capabilities: (json['capabilities'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
          verified: (json['verified'] as bool?) ?? false,
          lastSeen: json['last_seen'] != null
              ? DateTime.tryParse(json['last_seen'].toString()) ?? DateTime.now()
              : DateTime.now(),
        ),
      _ => throw FormatException('Invalid JSON for Agent: $json'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'did': did,
      'name': name,
      'avatar': avatar,
      'role': role,
      'status': status.toWireString(),
      'org': org,
      'capabilities': capabilities,
      'verified': verified,
      'last_seen': lastSeen.toIso8601String(),
    };
  }

  Agent copyWith({
    String? did,
    String? name,
    String? avatar,
    String? role,
    AgentStatus? status,
    String? org,
    List<String>? capabilities,
    bool? verified,
    DateTime? lastSeen,
  }) {
    return Agent(
      did: did ?? this.did,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      status: status ?? this.status,
      org: org ?? this.org,
      capabilities: capabilities ?? this.capabilities,
      verified: verified ?? this.verified,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
