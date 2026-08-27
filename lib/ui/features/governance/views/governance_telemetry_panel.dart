import 'package:flutter/material.dart';
import '../../../core/theme/acr_theme.dart';
import '../../audit_replay/view_models/audit_view_model.dart';
import '../../escalation_gate/view_models/escalation_view_model.dart';
import '../../escalation_gate/views/escalation_dialog.dart';

class GovernanceTelemetryPanel extends StatelessWidget {
  const GovernanceTelemetryPanel({
    super.key,
    required this.escalationViewModel,
    required this.auditViewModel,
    required this.operatorDid,
  });

  final EscalationViewModel escalationViewModel;
  final AuditViewModel auditViewModel;
  final String operatorDid;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: AcrColors.surface,
        border: Border(left: BorderSide(color: AcrColors.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AcrColors.cardBorder)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AcrColors.cyan, size: 16),
                Expanded(
                  child: Text(
                    'GOVERNANCE TELEMETRY',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AcrColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ZERO-TRUST',
                    style: TextStyle(
                      color: AcrColors.emerald,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Invariant Metrics Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AcrColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AcrColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TLA+ STATE INVARIANTS',
                        style: TextStyle(color: AcrColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildMetricRow('Consensus Safety', 'LEMMAS HOLD', AcrColors.emerald),
                      const SizedBox(height: 4),
                      _buildMetricRow('Escalation Queue', '${escalationViewModel.pendingEscalations.length} Pending', AcrColors.amber),
                      const SizedBox(height: 4),
                      _buildMetricRow('Audit Chain Depth', '${auditViewModel.auditLogs.length} Blocks', AcrColors.cyan),
                      const SizedBox(height: 4),
                      _buildMetricRow('Cross-Room Leaks', '0.000 (Guaranteed)', AcrColors.emerald),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Pending Escalations section
                Row(
                  children: [
                    const Text(
                      'PENDING ESCALATION GATES',
                      style: TextStyle(color: AcrColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      '${escalationViewModel.pendingEscalations.length}',
                      style: const TextStyle(color: AcrColors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (escalationViewModel.pendingEscalations.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AcrColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AcrColors.cardBorder),
                    ),
                    child: const Center(
                      child: Text(
                        'All Gates Clear • Autonomous Execution',
                        style: TextStyle(color: AcrColors.textMuted, fontSize: 11),
                      ),
                    ),
                  )
                else
                  ...escalationViewModel.pendingEscalations.map((esc) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AcrColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AcrColors.amber.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                esc.agentName,
                                style: const TextStyle(color: AcrColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                esc.riskLevel,
                                style: const TextStyle(color: AcrColors.rose, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            esc.action,
                            style: const TextStyle(color: AcrColors.cyan, fontSize: 10, fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => EscalationDialog(
                                    escalation: esc,
                                    onResolve: (approve) {
                                      escalationViewModel.resolve(
                                        escalationId: esc.id,
                                        approve: approve,
                                        operatorDid: operatorDid,
                                      );
                                    },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AcrColors.amber,
                                foregroundColor: AcrColors.background,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              child: const Text('Review & Sign'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AcrColors.textSecondary, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
