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
          backgroundColor: AcrColors.background,
          appBar: _buildAppBar(
            context,
            showDrawer: isMobile,
            isCompact: isMobile,
          ),
          drawer: isMobile
              ? Drawer(
                  backgroundColor: AcrColors.surface,
                  child: SafeArea(
                    child: Column(
                      children: [
                        _buildNavTabs(),
                        const Divider(color: AcrColors.subtleBorder),
                        Expanded(
                          child: BuddyListView(viewModel: buddyListViewModel),
                        ),
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
                      Expanded(
                        child: BuddyListView(viewModel: buddyListViewModel),
                      ),
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
        border: Border(bottom: BorderSide(color: AcrColors.subtleBorder)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: navItems.map((item) {
            final isSelected = item.path == '/'
                ? (currentPath == '/' || currentPath.startsWith('/rooms/'))
                : currentPath == item.path;
            return Semantics(
              button: true,
              selected: isSelected,
              label: '${item.label} tab',
              child: InkWell(
                onTap: () => onNavigate?.call(item.path),
                borderRadius: BorderRadius.circular(8),
                focusColor: AcrColors.zyphraGlow,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AcrColors.zyphraOrange.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: AcrColors.zyphraOrange.withValues(
                              alpha: 0.45,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 14,
                        color: isSelected
                            ? AcrColors.solarTint
                            : AcrColors.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? AcrColors.solarTint
                              : AcrColors.textSecondary,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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
      backgroundColor: AcrColors.surface,
      leading: showDrawer
          ? Builder(
              builder: (ctx) => IconButton(
                tooltip: 'Open navigation drawer',
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
              color: AcrColors.zyphraOrange.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hub,
              color: AcrColors.zyphraOrange,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'ACR',
            style: TextStyle(
              color: AcrColors.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AcrColors.zyphraOrange.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AcrColors.zyphraOrange.withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              'PROTOCOL',
              style: TextStyle(
                fontFamily: AcrTypography.monoFontFamily,
                fontFamilyFallback: AcrTypography.monoFallback,
                color: AcrColors.solarTint,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(width: 14),
            // Health Metric Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AcrColors.cardOverlay,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AcrColors.subtleBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AcrColors.emerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Mesh: 99.99% (0.38ms)',
                    style: TextStyle(
                      color: AcrColors.textSecondary,
                      fontSize: 10,
                      fontFamily: AcrTypography.monoFontFamily,
                      fontFamilyFallback: AcrTypography.monoFallback,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Operator DID Identity Chip
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AcrColors.cardOverlay,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AcrColors.subtleBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: AcrColors.solarTint,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        operatorDid,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AcrColors.textPrimary,
                          fontSize: 10,
                          fontFamily: AcrTypography.monoFontFamily,
                          fontFamilyFallback: AcrTypography.monoFallback,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
