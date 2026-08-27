import 'package:flutter/material.dart';
import '../../../../domain/models/mcp_tool_call.dart';
import '../../../core/theme/acr_theme.dart';

class McpToolCard extends StatelessWidget {
  const McpToolCard({super.key, required this.toolCall});

  final McpToolCall toolCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AcrColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AcrColors.cyan.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_outlined, color: AcrColors.cyan, size: 14),
              const SizedBox(width: 6),
              Text(
                toolCall.toolName,
                style: const TextStyle(
                  color: AcrColors.cyan,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AcrColors.card,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${toolCall.latencyMs.toStringAsFixed(2)}ms',
                  style: const TextStyle(
                    color: AcrColors.emerald,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          if (toolCall.output != null && toolCall.output!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(6),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AcrColors.background,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                toolCall.output!,
                style: const TextStyle(
                  color: AcrColors.textSecondary,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
