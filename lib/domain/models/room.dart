class Room {
  final String id;
  final String name;
  final String description;
  final String topic;
  final bool isPrivate;
  final List<String> participants;
  final DateTime createdAt;
  final int messageCount;

  const Room({
    required this.id,
    required this.name,
    required this.description,
    required this.topic,
    required this.isPrivate,
    required this.participants,
    required this.createdAt,
    required this.messageCount,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String id,
        'name': String name,
      } =>
        Room(
          id: id,
          name: name,
          description: (json['description'] as String?) ?? '',
          topic: (json['topic'] as String?) ?? '',
          isPrivate: (json['is_private'] as bool?) ?? false,
          participants: (json['participants'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
          createdAt: json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
          messageCount: (json['message_count'] as num?)?.toInt() ?? 0,
        ),
      _ => throw FormatException('Invalid JSON for Room: $json'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'topic': topic,
      'is_private': isPrivate,
      'participants': participants,
      'created_at': createdAt.toIso8601String(),
      'message_count': messageCount,
    };
  }
}
