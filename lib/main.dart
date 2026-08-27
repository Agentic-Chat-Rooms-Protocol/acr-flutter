import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/agent_repository.dart';
import 'data/repositories/governance_repository.dart';
import 'data/repositories/room_repository.dart';
import 'data/services/acr_gateway_service.dart';
import 'domain/use_cases/get_audit_trail_use_case.dart';
import 'domain/use_cases/resolve_escalation_use_case.dart';
import 'domain/use_cases/send_message_use_case.dart';
import 'routing/app_router.dart';
import 'ui/core/theme/acr_theme.dart';
import 'ui/features/audit_replay/view_models/audit_view_model.dart';
import 'ui/features/buddy_list/view_models/buddy_list_view_model.dart';
import 'ui/features/escalation_gate/view_models/escalation_view_model.dart';
import 'ui/features/room_chat/view_models/room_chat_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Data Layer: Services & Repositories
  final gatewayService = AcrGatewayService();
  final agentRepository = AgentRepository(gatewayService: gatewayService);
  final roomRepository = RoomRepository(gatewayService: gatewayService);
  final governanceRepository = GovernanceRepository(gatewayService: gatewayService);

  // 2. Domain Layer: Use Cases
  final sendMessageUseCase = SendMessageUseCase(repository: roomRepository);
  final resolveEscalationUseCase = ResolveEscalationUseCase(repository: governanceRepository);
  final getAuditTrailUseCase = GetAuditTrailUseCase(repository: governanceRepository);

  // 3. UI Layer: ViewModels
  final buddyListViewModel = BuddyListViewModel(agentRepository: agentRepository);
  final roomChatViewModel = RoomChatViewModel(
    roomRepository: roomRepository,
    sendMessageUseCase: sendMessageUseCase,
  );
  final escalationViewModel = EscalationViewModel(
    governanceRepository: governanceRepository,
    resolveEscalationUseCase: resolveEscalationUseCase,
  );
  final auditViewModel = AuditViewModel(getAuditTrailUseCase: getAuditTrailUseCase);

  // Initial Load
  buddyListViewModel.loadAgents();
  roomChatViewModel.loadRooms();
  escalationViewModel.loadEscalations();
  auditViewModel.loadAuditLogs();

  final router = createAcrRouter(
    buddyListViewModel: buddyListViewModel,
    roomChatViewModel: roomChatViewModel,
    escalationViewModel: escalationViewModel,
    auditViewModel: auditViewModel,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: buddyListViewModel),
        ChangeNotifierProvider.value(value: roomChatViewModel),
        ChangeNotifierProvider.value(value: escalationViewModel),
        ChangeNotifierProvider.value(value: auditViewModel),
      ],
      child: AcrApp(router: router),
    ),
  );
}

class AcrApp extends StatelessWidget {
  const AcrApp({super.key, required this.router});

  final dynamic router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ACR Protocol — Agentic Chat Surface',
      debugShowCheckedModeBanner: false,
      theme: AcrTheme.darkTheme,
      routerConfig: router,
    );
  }
}
