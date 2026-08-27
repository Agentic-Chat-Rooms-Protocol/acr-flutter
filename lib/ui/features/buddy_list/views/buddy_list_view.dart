import 'package:flutter/material.dart';
import '../../../../domain/models/agent.dart';
import '../../../core/theme/acr_theme.dart';
import '../../../core/widgets/status_badge.dart';
import '../view_models/buddy_list_view_model.dart';

class BuddyListView extends StatelessWidget {
  const BuddyListView({super.key, required this.viewModel});

  final BuddyListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading && viewModel.agents.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AcrColors.cyan));
        }

        if (viewModel.error != null && viewModel.agents.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AcrColors.rose, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Connection offline',
                  style: const TextStyle(color: AcrColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => viewModel.loadAgents(forceRefresh: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AcrColors.card,
                    foregroundColor: AcrColors.cyan,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Container(
          width: 280,
          decoration: const BoxDecoration(
            color: AcrColors.surface,
            border: Border(right: BorderSide(color: AcrColors.cardBorder)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AIM-style Roster Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AcrColors.cardBorder)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hub_outlined, color: AcrColors.cyan, size: 18),
                    Expanded(
                      child: Text(
                        'AGENT BUDDY LIST',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AcrColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AcrColors.cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${viewModel.agents.length}',
                        style: const TextStyle(
                          color: AcrColors.cyan,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Roster Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildSectionHeader('AUTONOMOUS AGENTS', viewModel.autonomousAgents.length),
                    ...viewModel.autonomousAgents.map((a) => _buildAgentTile(context, a)),
                    const SizedBox(height: 12),
                    _buildSectionHeader('OPERATOR & SENTINELS', viewModel.humanOperators.length),
                    ...viewModel.humanOperators.map((a) => _buildAgentTile(context, a)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AcrColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          Text(
            '$count',
            style: const TextStyle(color: AcrColors.textMuted, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentTile(BuildContext context, Agent agent) {
    return InkWell(
      onTap: () => _showAgentCard(context, agent),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 14,
              backgroundColor: AcrColors.card,
              child: Text(
                agent.name.substring(0, 1),
                style: const TextStyle(
                  color: AcrColors.cyan,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AcrColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    agent.org,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AcrColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            StatusBadge(status: agent.status),
          ],
        ),
      ),
    );
  }

  void _showAgentCard(BuildContext context, Agent agent) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AcrColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AcrColors.cardBorder),
          ),
          title: Row(
            children: [
              const Icon(Icons.verified_user_outlined, color: AcrColors.cyan, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  agent.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DID: ${agent.did}', style: const TextStyle(color: AcrColors.cyan, fontSize: 11, fontFamily: 'monospace')),
              const SizedBox(height: 6),
              Text('Organization: ${agent.org}', style: const TextStyle(color: AcrColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
              const Text('CAPABILITY CREDENTIAL SCOPES:', style: TextStyle(color: AcrColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: agent.capabilities.map((c) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AcrColors.indigo.withValues(alpha: 0.15),
                      border: Border.all(color: AcrColors.indigo.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(c, style: const TextStyle(color: AcrColors.textPrimary, fontSize: 10, fontFamily: 'monospace')),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close', style: TextStyle(color: AcrColors.cyan)),
            ),
          ],
        );
      },
    );
  }
}
