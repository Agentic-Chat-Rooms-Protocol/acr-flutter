import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acr_flutter/domain/models/agent.dart';
import 'package:acr_flutter/domain/models/escalation.dart';
import 'package:acr_flutter/domain/models/room.dart';
import 'package:acr_flutter/ui/core/widgets/status_badge.dart';

void main() {
  test('Agent domain model copyWith updates presence status', () {
    final agent = Agent(
      did: 'did:key:z6Mkq5Xv',
      name: 'Claude Code Reviewer',
      avatar: '',
      role: 'agent',
      status: AgentStatus.online,
      org: 'Anthropic Autonomous Engineering',
      capabilities: ['chat.*', 'mcp.ast_diff'],
      verified: true,
      lastSeen: DateTime.now(),
    );

    final updated = agent.copyWith(status: AgentStatus.deliberating);
    expect(updated.status, AgentStatus.deliberating);
    expect(updated.name, 'Claude Code Reviewer');
  });

  test('Escalation domain model handles resolution states', () {
    final esc = Escalation(
      id: 'esc-001',
      requestingDid: 'did:key:z6Mkp2x1',
      agentName: 'Devin',
      roomId: 'consensus-main',
      action: 'k8s.deploy',
      riskLevel: 'HIGH',
      payload: '{"target":"prod"}',
      status: EscalationStatus.pending,
      createdAt: DateTime.now(),
    );

    final resolved = esc.copyWith(
      status: EscalationStatus.approved,
      operatorDid: 'did:key:z6Mka881...operator',
      signature: 'sig-test-123',
    );

    expect(resolved.status, EscalationStatus.approved);
    expect(resolved.operatorDid, 'did:key:z6Mka881...operator');
    expect(resolved.signature, 'sig-test-123');
  });

  test('Room domain model holds topic and message counts', () {
    final room = Room(
      id: 'consensus-main',
      name: 'Consensus Main',
      description: 'Primary deliberation floor',
      topic: 'W3C DID/VC • TLA+ Verified Merges',
      isPrivate: false,
      participants: ['did:key:z6Mkq5Xv'],
      createdAt: DateTime.now(),
      messageCount: 42,
    );

    expect(room.id, 'consensus-main');
    expect(room.messageCount, 42);
  });

  testWidgets('StatusBadge renders status label and indicator', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: StatusBadge(status: AgentStatus.deliberating),
      ),
    );

    expect(find.text('Deliberating'), findsOneWidget);
  });
}
