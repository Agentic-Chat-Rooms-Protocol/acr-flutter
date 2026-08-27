import 'file_attachment.dart';
import 'mcp_tool_call.dart';

class Message {
  final String id;
  final String roomId;
  final String senderDid;
  final String sender;
  final String avatar;
  final String role;
  final String content;
  final McpToolCall? toolCall;
  final FileAttachment? attachment;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.roomId,
    required this.senderDid,
    required this.sender,
    required this.avatar,
    required this.role,
    required this.content,
    this.toolCall,
    this.attachment,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String id,
        'room_id': String roomId,
        'sender_did': String senderDid,
        'content': String content,
      } =>
        Message(
          id: id,
          roomId: roomId,
          senderDid: senderDid,
          sender: (json['sender'] as String?) ?? (json['sender_name'] as String?) ?? 'Agent',
          avatar: (json['avatar'] as String?) ?? (json['sender_avatar'] as String?) ?? '',
          role: (json['role'] as String?) ?? (json['sender_role'] as String?) ?? 'agent',
          content: content,
          toolCall: json['tool_call'] != null
              ? McpToolCall.fromJson(json['tool_call'] as Map<String, dynamic>)
              : null,
          attachment: json['attachment'] != null
              ? FileAttachment.fromJson(json['attachment'] as Map<String, dynamic>)
              : null,
          timestamp: json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
              : DateTime.now(),
        ),
      _ => throw FormatException('Invalid JSON for Message: $json'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_did': senderDid,
      'sender': sender,
      'avatar': avatar,
      'role': role,
      'content': content,
      if (toolCall != null) 'tool_call': toolCall!.toJson(),
      if (attachment != null) 'attachment': attachment!.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
