import 'package:acr_flutter/data/repositories/agent_repository.dart';
import 'package:acr_flutter/data/repositories/governance_repository.dart';
import 'package:acr_flutter/data/repositories/room_repository.dart';
import 'package:acr_flutter/data/services/acr_gateway_service.dart';
import 'package:acr_flutter/domain/models/mcp_tool_call.dart';
import 'package:acr_flutter/domain/models/message.dart';
import 'package:acr_flutter/domain/models/proposal.dart';
import 'package:acr_flutter/domain/models/room.dart';
import 'package:acr_flutter/domain/use_cases/get_audit_trail_use_case.dart';
import 'package:acr_flutter/domain/use_cases/resolve_escalation_use_case.dart';
import 'package:acr_flutter/domain/use_cases/send_message_use_case.dart';
import 'package:acr_flutter/features/approvals/screens/approval_decision_sheet.dart';
import 'package:acr_flutter/ui/core/layout/adaptive_scaffold.dart';
import 'package:acr_flutter/ui/core/theme/acr_theme.dart';
import 'package:acr_flutter/ui/features/audit_replay/view_models/audit_view_model.dart';
import 'package:acr_flutter/ui/features/buddy_list/view_models/buddy_list_view_model.dart';
import 'package:acr_flutter/ui/features/escalation_gate/view_models/escalation_view_model.dart';
import 'package:acr_flutter/ui/features/room_chat/view_models/room_chat_view_model.dart';
import 'package:acr_flutter/ui/features/room_chat/views/proposals_banner_view.dart';
import 'package:acr_flutter/ui/features/room_chat/views/room_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeRoomChatViewModel extends RoomChatViewModel {
  _FakeRoomChatViewModel({required Room room, required List<Message> messages})
    : _fakeRoom = room,
      _fakeMessages = messages,
      super(
        roomRepository: RoomRepository(
          gatewayService: AcrGatewayService(
            environment: const {},
            homeDirectory: '',
          ),
        ),
        sendMessageUseCase: SendMessageUseCase(
          repository: RoomRepository(
            gatewayService: AcrGatewayService(
              environment: const {},
              homeDirectory: '',
            ),
          ),
        ),
      );

  final Room _fakeRoom;
  final List<Message> _fakeMessages;
  final List<String> sentMessages = [];

  @override
  Room? get selectedRoom => _fakeRoom;

  @override
  List<Message> get messages => _fakeMessages;

  @override
  Future<void> sendMessage(
    String content, {
    required String operatorDid,
  }) async {
    sentMessages.add(content);
  }
}

void main() {
  group('AcrTheme Obsidian & Zyphra Design System Tokens', () {
    test(
      'exposes canonical Obsidian, Zyphra Orange, and typography tokens',
      () {
        final theme = AcrTheme.darkTheme;

        expect(AcrColors.background, const Color(0xFF000000));
        expect(AcrColors.surface, const Color(0xFF0D0D11));
        expect(AcrColors.zyphraOrange, const Color(0xFFFF5500));
        expect(AcrColors.solarTint, const Color(0xFFFF8C42));
        expect(AcrColors.graphite, const Color(0xFF18181B));
        expect(AcrColors.copper, const Color(0xFFE7620F));

        expect(theme.scaffoldBackgroundColor, const Color(0xFF000000));
        expect(theme.colorScheme.surface, const Color(0xFF0D0D11));
        expect(theme.colorScheme.primary, const Color(0xFFFF5500));
        expect(theme.colorScheme.onPrimary, const Color(0xFF000000));
        expect(theme.colorScheme.secondary, const Color(0xFFFF8C42));
        expect(AcrTypography.sansFontFamily, 'Inter');
        expect(AcrTypography.monoFontFamily, 'Atkinson Hyperlegible Mono');

        expect(
          theme.elevatedButtonTheme.style?.minimumSize?.resolve({}),
          const Size(44, 44),
        );
        expect(
          theme.outlinedButtonTheme.style?.minimumSize?.resolve({}),
          const Size(44, 44),
        );
        expect(
          theme.textButtonTheme.style?.minimumSize?.resolve({}),
          const Size(44, 44),
        );
        expect(
          theme.iconButtonTheme.style?.minimumSize?.resolve({}),
          const Size(44, 44),
        );
      },
    );
  });

  group('ApprovalDecisionSheet', () {
    testWidgets(
      'supports reject and biometric confirm decisions with >=44px controls',
      (tester) async {
        bool? lastApproved;
        String? lastReason;

        await tester.pumpWidget(
          MaterialApp(
            theme: AcrTheme.darkTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => ApprovalDecisionSheet(
                        actionId: 'sha256:deadbeef',
                        kind: 'k8s.deploy',
                        summary: 'Promote canary deployment to production',
                        proposer: 'did:key:agent1',
                        onDecision: (approved, reason) {
                          lastApproved = approved;
                          lastReason = reason;
                        },
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('CRITICAL APPROVAL GATE'), findsOneWidget);
        expect(find.text('Action: K8S.DEPLOY'), findsOneWidget);
        expect(
          tester
              .getSize(find.widgetWithText(OutlinedButton, 'VETO / REJECT'))
              .height,
          greaterThanOrEqualTo(44),
        );
        expect(
          tester
              .getSize(
                find.widgetWithText(ElevatedButton, 'CONFIRM (BIOMETRIC)'),
              )
              .height,
          greaterThanOrEqualTo(44),
        );

        await tester.enterText(find.byType(TextField), 'Verified checksum');
        await tester.tap(find.text('CONFIRM (BIOMETRIC)'));
        await tester.pumpAndSettle();

        expect(lastApproved, isTrue);
        expect(lastReason, 'Verified checksum');

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Unsafe window');
        await tester.tap(find.text('VETO / REJECT'));
        await tester.pumpAndSettle();

        expect(lastApproved, isFalse);
        expect(lastReason, 'Unsafe window');
      },
    );
  });

  group('AdaptiveScaffold & RoomChatView Responsive / WCAG Behavior', () {
    late BuddyListViewModel buddyVM;
    late EscalationViewModel escVM;
    late AuditViewModel auditVM;

    setUp(() {
      final gateway = AcrGatewayService(
        client: MockClient((_) async => http.Response('[]', 200)),
        environment: const {},
        homeDirectory: '',
      );
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

    testWidgets(
      'renders cleanly at 360px mobile width and 700px tablet boundary',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final room = Room(
          id: 'consensus-main',
          name: 'Consensus Deliberation Floor With Very Long Title',
          description: 'Desc',
          topic: 'W3C DID / TLA+ Verified Merges & Long Topic Badge',
          isPrivate: false,
          participants: const ['did:key:1'],
          createdAt: DateTime.utc(2026, 11, 18),
          messageCount: 1,
        );
        final chatVM = _FakeRoomChatViewModel(
          room: room,
          messages: [
            Message(
              id: 'msg-1',
              roomId: room.id,
              senderDid: 'did:key:agent',
              sender: 'Agent With Long Identifier Name',
              avatar: '',
              role: 'agent',
              content: 'Check passed',
              toolCall: const McpToolCall(
                id: 't1',
                toolName: 'mcp.ast_diff',
                arguments: '{}',
                output: 'OK',
                status: 'completed',
                latencyMs: 0.38,
              ),
              timestamp: DateTime.utc(2026, 11, 18, 12, 0),
            ),
          ],
        );

        for (final width in [360.0, 700.0]) {
          tester.view.physicalSize = Size(width, 800);
          await tester.pumpWidget(
            MaterialApp(
              theme: AcrTheme.darkTheme,
              home: AdaptiveScaffold(
                currentPath: '/rooms/consensus-main',
                buddyListViewModel: buddyVM,
                escalationViewModel: escVM,
                auditViewModel: auditVM,
                operatorDid: 'did:key:z6Mka881...very_long_operator_did',
                body: RoomChatView(
                  chatViewModel: chatVM,
                  escalationViewModel: escVM,
                  operatorDid: 'did:key:z6Mka881...operator',
                ),
              ),
            ),
          );

          expect(tester.takeException(), isNull);
          expect(find.text('mcp.ast_diff'), findsOneWidget);
        }

        await tester.enterText(find.byType(TextField), 'Proceed with canary');
        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump();
        expect(chatVM.sentMessages, ['Proceed with canary']);
      },
    );

    testWidgets(
      'ProposalsBannerView records approve vote and dissent rationale safely',
      (tester) async {
        final recordedVotes = <(String, String, String?)>[];
        final proposal = Proposal(
          id: 'cip-104',
          roomId: 'consensus-main',
          title: 'Enforce Bearer Token Auth',
          description: 'Require Bearer token for daemon gateway endpoints.',
          proposerDid: 'did:key:proposer',
          options: const ['APPROVE', 'REJECT', 'DISSENT'],
          votes: const {},
          dissentLogs: const [],
          status: 'open',
          createdAt: DateTime.utc(2026, 11, 18),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AcrTheme.darkTheme,
            home: Scaffold(
              body: ProposalsBannerView(
                proposals: [proposal],
                currentVoterDid: 'did:key:op',
                onVote: (id, choice, {rationale}) async {
                  recordedVotes.add((id, choice, rationale));
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Approve'));
        await tester.pump();
        expect(recordedVotes, [('cip-104', 'APPROVE', null)]);

        await tester.tap(find.text('Dissent...'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Needs rotation test');
        await tester.tap(find.text('Anchor Dissent'));
        await tester.pumpAndSettle();

        expect(recordedVotes.last, (
          'cip-104',
          'DISSENT',
          'Needs rotation test',
        ));
        expect(tester.takeException(), isNull);
      },
    );
  });
}
