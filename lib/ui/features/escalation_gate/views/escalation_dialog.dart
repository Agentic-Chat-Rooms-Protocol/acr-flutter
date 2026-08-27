import 'package:flutter/material.dart';
import '../../../../domain/models/escalation.dart';
import '../../../core/theme/acr_theme.dart';

class EscalationDialog extends StatelessWidget {
  const EscalationDialog({
    super.key,
    required this.escalation,
    required this.onResolve,
  });

  final Escalation escalation;
  final void Function(bool approve) onResolve;

  Color get _riskColor {
    switch (escalation.riskLevel) {
      case 'CRITICAL':
        return AcrColors.rose;
      case 'HIGH':
        return AcrColors.amber;
      case 'MEDIUM':
        return AcrColors.cyan;
      default:
        return AcrColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AcrColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _riskColor.withValues(alpha: 0.5), width: 1.2),
      ),
      title: Row(
        children: [
          Icon(Icons.shield_outlined, color: _riskColor, size: 22),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'HUMAN ESCALATION GATE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _riskColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _riskColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              escalation.riskLevel,
              style: TextStyle(
                color: _riskColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agent ${escalation.agentName} requested high-privilege authorization:',
              style: const TextStyle(color: AcrColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AcrColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AcrColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: AcrColors.amber, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        escalation.action,
                        style: const TextStyle(
                          color: AcrColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'DID: ${escalation.requestingDid}',
                    style: const TextStyle(color: AcrColors.textMuted, fontSize: 10, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'PAYLOAD PREVIEW:',
              style: TextStyle(color: AcrColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AcrColors.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                escalation.payload,
                style: const TextStyle(color: AcrColors.cyan, fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onResolve(false);
          },
          child: const Text('Reject', style: TextStyle(color: AcrColors.rose)),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onResolve(true);
          },
          icon: const Icon(Icons.verified, size: 16),
          label: const Text('Approve & Sign (Ed25519)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AcrColors.cyan,
            foregroundColor: AcrColors.background,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
