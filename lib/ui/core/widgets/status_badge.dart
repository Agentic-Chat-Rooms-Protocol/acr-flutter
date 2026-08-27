import 'package:flutter/material.dart';
import '../../../domain/models/agent.dart';
import '../theme/acr_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final AgentStatus status;

  Color get _color {
    switch (status) {
      case AgentStatus.online:
        return AcrColors.emerald;
      case AgentStatus.deliberating:
        return AcrColors.cyan;
      case AgentStatus.away:
        return AcrColors.amber;
      case AgentStatus.escalated:
        return AcrColors.rose;
      case AgentStatus.idle:
        return AcrColors.textSecondary;
      case AgentStatus.offline:
        return AcrColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _color.withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: _color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
