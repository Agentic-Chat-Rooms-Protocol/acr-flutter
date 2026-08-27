class McpToolCall {
  final String id;
  final String toolName;
  final String arguments;
  final String? output;
  final String status;
  final double latencyMs;

  const McpToolCall({
    required this.id,
    required this.toolName,
    required this.arguments,
    this.output,
    required this.status,
    required this.latencyMs,
  });

  factory McpToolCall.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String id,
        'tool_name': String toolName,
      } =>
        McpToolCall(
          id: id,
          toolName: toolName,
          arguments: json['arguments']?.toString() ?? '',
          output: json['output']?.toString(),
          status: (json['status'] as String?) ?? 'completed',
          latencyMs: (json['latency_ms'] as num?)?.toDouble() ?? 0.0,
        ),
      _ => throw FormatException('Invalid JSON for McpToolCall: $json'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tool_name': toolName,
      'arguments': arguments,
      if (output != null) 'output': output,
      'status': status,
      'latency_ms': latencyMs,
    };
  }
}
