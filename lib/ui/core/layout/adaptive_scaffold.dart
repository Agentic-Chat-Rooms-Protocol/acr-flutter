import 'package:flutter/material.dart';
import '../../features/audit_replay/view_models/audit_view_model.dart';
import '../../features/buddy_list/view_models/buddy_list_view_model.dart';
import '../../features/buddy_list/views/buddy_list_view.dart';
import '../../features/escalation_gate/view_models/escalation_view_model.dart';
import '../../features/governance/views/governance_telemetry_panel.dart';
import '../theme/acr_theme.dart';

const double kDesktopBreakpoint = 1050.0;
const double kTabletBreakpoint = 700.0;

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.buddyListViewModel,
    required this.escalationViewModel,
    required this.auditViewModel,
    required this.operatorDid,
    this.currentPath = '/',
    this.onNavigate,
  });

  final Widget body;
  final BuddyListViewModel buddyListViewModel;
  final EscalationViewModel escalationViewModel;
  final AuditViewModel auditViewModel;
  final String operatorDid;
  final String currentPath;
  final void Function(String path)? onNavigate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
        final isMobile = constraints.maxWidth < kTabletBreakpoint;

        return Scaffold(
          appBar: _buildAppBar(context, showDrawer: isMobile, isCompact: isMobile),
          drawer: isMobile
              ? Drawer(
                  backgroundColor: AcrColors.surface,
                  child: SafeArea(
                    child: Column(
                      children: [
                        _buildNavTabs(),
                        const Divider(color: AcrColors.cardBorder),
                        Expanded(child: BuddyListView(viewModel: buddyListViewModel)),
                      ],
                    ),
                  ),
                )
              : null,
          body: Row(
            children: [
              // Left: Buddy List on Desktop & Tablet
              if (!isMobile)
                SizedBox(
                  width: isDesktop ? 280 : 250,
                  child: Column(
                    children: [
                      _buildNavTabs(),
                      Expanded(child: BuddyListView(viewModel: buddyListViewModel)),
                    ],
                  ),
                ),

              // Center: Primary Content Area (Expanded)
              Expanded(child: body),

              // Right: Telemetry Panel on Desktop
              if (isDesktop)
                GovernanceTelemetryPanel(
                  escalationViewModel: escalationViewModel,
                  auditViewModel: auditViewModel,
                  operatorDid: operatorDid,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavTabs() {
    final navItems = [
      (path: '/', icon: Icons.forum_outlined, label: 'Consensus'),
      (path: '/escalations', icon: Icons.shield_outlined, label: 'Gates'),
      (path: '/audit', icon: Icons.account_tree_outlined, label: 'Audit'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: const BoxDecoration(
        color: AcrColors.surface,
        border: Border(bottom: BorderSide(color: AcrColors.cardBorder)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: navItems.map((item) {
            final isSelected = currentPath == item.path;
            return InkWell(
              onTap: () => onNavigate?.call(item.path),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? AcrColors.cyan.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: isSelected ? Border.all(color: AcrColors.cyan.withValues(alpha: 0.3)) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 13, color: isSelected ? AcrColors.cyan : AcrColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? AcrColors.cyan : AcrColors.textSecondary,
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context, {
    required bool showDrawer,
    required bool isCompact,
  }) {
    return AppBar(
      titleSpacing: 16,
      leading: showDrawer
          ? Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: AcrColors.textSecondary),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )
          : null,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AcrColors.cyan.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hub, color: AcrColors.cyan, size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            'ACR',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AcrColors.cyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AcrColors.cyan.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'PROTOCOL',
              style: TextStyle(color: AcrColors.cyan, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(width: 14),
            // Health Metric Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AcrColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AcrColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AcrColors.emerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Mesh: 99.99% (0.38ms)',
                    style: TextStyle(color: AcrColors.textSecondary, fontSize: 10, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Operator DID Identity Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AcrColors.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AcrColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings_outlined, color: AcrColors.cyan, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    operatorDid,
                    style: const TextStyle(
                      color: AcrColors.textPrimary,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
