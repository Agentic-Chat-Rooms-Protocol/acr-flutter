import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acr_flutter/data/repositories/agent_repository.dart';
import 'package:acr_flutter/data/repositories/governance_repository.dart';
import 'package:acr_flutter/data/services/acr_gateway_service.dart';
import 'package:acr_flutter/domain/use_cases/get_audit_trail_use_case.dart';
import 'package:acr_flutter/domain/use_cases/resolve_escalation_use_case.dart';
import 'package:acr_flutter/ui/core/layout/adaptive_scaffold.dart';
import 'package:acr_flutter/ui/features/audit_replay/view_models/audit_view_model.dart';
import 'package:acr_flutter/ui/features/buddy_list/view_models/buddy_list_view_model.dart';
import 'package:acr_flutter/ui/features/buddy_list/views/buddy_list_view.dart';
import 'package:acr_flutter/ui/features/escalation_gate/view_models/escalation_view_model.dart';
import 'package:acr_flutter/ui/features/governance/views/governance_telemetry_panel.dart';

void main() {
  late BuddyListViewModel buddyVM;
  late EscalationViewModel escVM;
  late AuditViewModel auditVM;

  setUp(() {
    final gateway = AcrGatewayService();
    final agentRepo = AgentRepository(gatewayService: gateway);
    final govRepo = GovernanceRepository(gatewayService: gateway);

    buddyVM = BuddyListViewModel(agentRepository: agentRepo);
    escVM = EscalationViewModel(
      governanceRepository: govRepo,
      resolveEscalationUseCase: ResolveEscalationUseCase(repository: govRepo),
    );
    auditVM = AuditViewModel(
      getAuditTrailUseCase: GetAuditTrailUseCase(repository: govRepo),
    );
  });

  testWidgets('AdaptiveScaffold renders 3 columns on Desktop (1200px width)', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          buddyListViewModel: buddyVM,
          escalationViewModel: escVM,
          auditViewModel: auditVM,
          operatorDid: 'did:key:test',
          body: const Center(child: Text('Desktop Center View')),
        ),
      ),
    );

    expect(find.text('Desktop Center View'), findsOneWidget);
    // Should find BuddyListView
    expect(find.byType(BuddyListView), findsOneWidget);
    // Should find GovernanceTelemetryPanel on Desktop
    expect(find.byType(GovernanceTelemetryPanel), findsOneWidget);
  });

  testWidgets('AdaptiveScaffold renders 2 columns on Tablet (800px width)', (tester) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          buddyListViewModel: buddyVM,
          escalationViewModel: escVM,
          auditViewModel: auditVM,
          operatorDid: 'did:key:test',
          body: const Center(child: Text('Tablet Center View')),
        ),
      ),
    );

    expect(find.text('Tablet Center View'), findsOneWidget);
    expect(find.byType(BuddyListView), findsOneWidget);
    // Telemetry panel is hidden on tablet
    expect(find.byType(GovernanceTelemetryPanel), findsNothing);
  });

  testWidgets('AdaptiveScaffold uses Drawer on Mobile (500px width)', (tester) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          buddyListViewModel: buddyVM,
          escalationViewModel: escVM,
          auditViewModel: auditVM,
          operatorDid: 'did:key:test',
          body: const Center(child: Text('Mobile Center View')),
        ),
      ),
    );

    expect(find.text('Mobile Center View'), findsOneWidget);
    // Sidebar BuddyListView is not in main body on mobile (it is in Drawer)
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });
}
