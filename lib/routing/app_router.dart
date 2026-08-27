import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/core/layout/adaptive_scaffold.dart';
import '../ui/features/audit_replay/view_models/audit_view_model.dart';
import '../ui/features/audit_replay/views/audit_timeline_view.dart';
import '../ui/features/buddy_list/view_models/buddy_list_view_model.dart';
import '../ui/features/escalation_gate/view_models/escalation_view_model.dart';
import '../ui/features/escalation_gate/views/escalations_inbox_view.dart';
import '../ui/features/room_chat/view_models/room_chat_view_model.dart';
import '../ui/features/room_chat/views/room_chat_view.dart';

const String kRootOperatorDid = 'did:key:z6Mka881...operator';

GoRouter createAcrRouter({
  required BuddyListViewModel buddyListViewModel,
  required RoomChatViewModel roomChatViewModel,
  required EscalationViewModel escalationViewModel,
  required AuditViewModel auditViewModel,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AdaptiveScaffold(
            currentPath: state.uri.path,
            onNavigate: (path) => context.go(path),
            buddyListViewModel: buddyListViewModel,
            escalationViewModel: escalationViewModel,
            auditViewModel: auditViewModel,
            operatorDid: kRootOperatorDid,
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return RoomChatView(
                chatViewModel: roomChatViewModel,
                escalationViewModel: escalationViewModel,
                operatorDid: kRootOperatorDid,
              );
            },
            routes: [
              GoRoute(
                path: 'rooms/:roomId',
                builder: (context, state) {
                  final roomId = state.pathParameters['roomId']!;
                  // Ensure room is loaded
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final matching = roomChatViewModel.rooms.where((r) => r.id == roomId);
                    if (matching.isNotEmpty) {
                      roomChatViewModel.selectRoom(matching.first);
                    }
                  });
                  return RoomChatView(
                    chatViewModel: roomChatViewModel,
                    escalationViewModel: escalationViewModel,
                    operatorDid: kRootOperatorDid,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/escalations',
            builder: (context, state) {
              return EscalationsInboxView(
                viewModel: escalationViewModel,
                operatorDid: kRootOperatorDid,
              );
            },
          ),
          GoRoute(
            path: '/audit',
            builder: (context, state) {
              return AuditTimelineView(
                viewModel: auditViewModel,
              );
            },
          ),
        ],
      ),
    ],
  );
}
