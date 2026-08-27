import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/acr_theme.dart';
import '../view_models/audit_view_model.dart';

class AuditTimelineView extends StatelessWidget {
  const AuditTimelineView({super.key, required this.viewModel});

  final AuditViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading && viewModel.auditLogs.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AcrColors.cyan));
        }

        if (viewModel.auditLogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_toggle_off, color: AcrColors.textMuted, size: 36),
                const SizedBox(height: 12),
                const Text(
                  'No Audit State Hashes Recorded',
                  style: TextStyle(color: AcrColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => viewModel.loadAuditLogs(forceRefresh: true),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Refresh Audit Chain'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AcrColors.card,
                    foregroundColor: AcrColors.cyan,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          color: AcrColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Audit Replay Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AcrColors.surface,
                  border: Border(bottom: BorderSide(color: AcrColors.cardBorder)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_tree_outlined, color: AcrColors.cyan, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'TLA+ VERIFIED AUDIT REPLAY (SHA-256 HASH CHAIN)',
                      style: TextStyle(
                        color: AcrColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AcrColors.card,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AcrColors.cardBorder),
                      ),
                      child: Text(
                        '${viewModel.auditLogs.length} BLOCKS',
                        style: const TextStyle(
                          color: AcrColors.emerald,
                          fontSize: 10,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AcrColors.textSecondary, size: 18),
                      onPressed: () => viewModel.loadAuditLogs(forceRefresh: true),
                      tooltip: 'Refresh Chain',
                    ),
                  ],
                ),
              ),

              // Timeline List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.auditLogs.length,
                  separatorBuilder: (ctx, i) => Container(
                    margin: const EdgeInsets.only(left: 20),
                    height: 16,
                    width: 2,
                    color: AcrColors.cyan.withValues(alpha: 0.3),
                  ),
                  itemBuilder: (context, index) {
                    final entry = viewModel.auditLogs[index];
                    final timeStr = DateFormat('HH:mm:ss.SSS').format(entry.timestamp);

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AcrColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AcrColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AcrColors.cyan.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#${entry.index.toString().padLeft(4, '0')}',
                                  style: const TextStyle(
                                    color: AcrColors.cyan,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.eventType,
                                style: const TextStyle(
                                  color: AcrColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  color: AcrColors.textMuted,
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (entry.payloadSummary.isNotEmpty)
                            Text(
                              entry.payloadSummary,
                              style: const TextStyle(color: AcrColors.textSecondary, fontSize: 11),
                            ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AcrColors.background,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('PREV: ', style: TextStyle(color: AcrColors.textMuted, fontSize: 9, fontFamily: 'monospace')),
                                    Expanded(
                                      child: Text(
                                        entry.previousHash,
                                        style: const TextStyle(color: AcrColors.textMuted, fontSize: 9, fontFamily: 'monospace'),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Text('CURR: ', style: TextStyle(color: AcrColors.cyan, fontSize: 9, fontFamily: 'monospace')),
                                    Expanded(
                                      child: Text(
                                        entry.stateHash,
                                        style: const TextStyle(color: AcrColors.cyan, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
