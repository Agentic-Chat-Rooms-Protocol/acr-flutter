import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/acr_theme.dart';
import '../view_models/escalation_view_model.dart';
import 'escalation_dialog.dart';

class EscalationsInboxView extends StatelessWidget {
  const EscalationsInboxView({
    super.key,
    required this.viewModel,
    required this.operatorDid,
  });

  final EscalationViewModel viewModel;
  final String operatorDid;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final escalations = viewModel.pendingEscalations;

        return Container(
          color: AcrColors.background,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AcrColors.surface,
                  border: Border(bottom: BorderSide(color: AcrColors.cardBorder)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AcrColors.amber, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'HUMAN ESCALATION GATES',
                      style: TextStyle(
                        color: AcrColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AcrColors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${escalations.length} PENDING SIGN-OFF',
                        style: const TextStyle(
                          color: AcrColors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AcrColors.textSecondary, size: 18),
                      onPressed: () => viewModel.loadEscalations(forceRefresh: true),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: escalations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_user_outlined, color: AcrColors.emerald, size: 40),
                            const SizedBox(height: 12),
                            const Text(
                              'All Escalation Gates Clear',
                              style: TextStyle(color: AcrColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Autonomous agents are operating within designated capability envelopes.',
                              style: TextStyle(color: AcrColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: escalations.length,
                        itemBuilder: (context, index) {
                          final esc = escalations[index];
                          final timeStr = DateFormat('HH:mm:ss').format(esc.createdAt);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AcrColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AcrColors.amber.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: AcrColors.amber, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      esc.agentName,
                                      style: const TextStyle(color: AcrColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AcrColors.rose.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        esc.riskLevel,
                                        style: const TextStyle(color: AcrColors.rose, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      timeStr,
                                      style: const TextStyle(color: AcrColors.textMuted, fontSize: 11, fontFamily: 'monospace'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Action: ${esc.action}',
                                  style: const TextStyle(color: AcrColors.cyan, fontSize: 12, fontFamily: 'monospace'),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Requesting DID: ${esc.requestingDid}',
                                  style: const TextStyle(color: AcrColors.textMuted, fontSize: 10, fontFamily: 'monospace'),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AcrColors.background,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    esc.payload,
                                    style: const TextStyle(color: AcrColors.textSecondary, fontSize: 11, fontFamily: 'monospace'),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        viewModel.resolve(
                                          escalationId: esc.id,
                                          approve: false,
                                          operatorDid: operatorDid,
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AcrColors.rose,
                                        side: const BorderSide(color: AcrColors.rose),
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => EscalationDialog(
                                            escalation: esc,
                                            onResolve: (approve) {
                                              viewModel.resolve(
                                                escalationId: esc.id,
                                                approve: approve,
                                                operatorDid: operatorDid,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.verified, size: 14),
                                      label: const Text('Review & Sign (Ed25519)'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AcrColors.cyan,
                                        foregroundColor: AcrColors.background,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
