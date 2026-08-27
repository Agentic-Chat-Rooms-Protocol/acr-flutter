import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/acr_theme.dart';
import '../../escalation_gate/view_models/escalation_view_model.dart';
import '../../escalation_gate/views/escalation_dialog.dart';
import '../view_models/room_chat_view_model.dart';
import 'mcp_tool_card.dart';

class RoomChatView extends StatefulWidget {
  const RoomChatView({
    super.key,
    required this.chatViewModel,
    required this.escalationViewModel,
    required this.operatorDid,
  });

  final RoomChatViewModel chatViewModel;
  final EscalationViewModel escalationViewModel;
  final String operatorDid;

  @override
  State<RoomChatView> createState() => _RoomChatViewState();
}

class _RoomChatViewState extends State<RoomChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    widget.chatViewModel.sendMessage(text, operatorDid: widget.operatorDid);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.chatViewModel, widget.escalationViewModel]),
      builder: (context, _) {
        final room = widget.chatViewModel.selectedRoom;
        final pendingEscalations = widget.escalationViewModel.pendingEscalations;

        if (widget.chatViewModel.isLoading && room == null) {
          return const Center(child: CircularProgressIndicator(color: AcrColors.cyan));
        }

        return Container(
          color: AcrColors.background,
          child: Column(
            children: [
              // Room Header
              if (room != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AcrColors.surface,
                    border: Border(bottom: BorderSide(color: AcrColors.cardBorder)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tag, color: AcrColors.cyan, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        room.name,
                        style: const TextStyle(
                          color: AcrColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AcrColors.card,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AcrColors.cardBorder),
                        ),
                        child: Text(
                          room.topic,
                          style: const TextStyle(
                            color: AcrColors.textMuted,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AcrColors.textSecondary, size: 18),
                        onPressed: () {
                          widget.chatViewModel.loadMessages(room.id, forceRefresh: true);
                          widget.escalationViewModel.loadEscalations(forceRefresh: true);
                        },
                        tooltip: 'Refresh Room',
                      ),
                    ],
                  ),
                ),

              // Pending Escalation Notification Banner
              if (pendingEscalations.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AcrColors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AcrColors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AcrColors.amber, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Human Escalation Required (${pendingEscalations.length} Pending)',
                              style: const TextStyle(
                                color: AcrColors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${pendingEscalations.first.agentName} requests ${pendingEscalations.first.action}',
                              style: const TextStyle(color: AcrColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => EscalationDialog(
                              escalation: pendingEscalations.first,
                              onResolve: (approve) {
                                widget.escalationViewModel.resolve(
                                  escalationId: pendingEscalations.first.id,
                                  approve: approve,
                                  operatorDid: widget.operatorDid,
                                );
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AcrColors.amber,
                          foregroundColor: AcrColors.background,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Review Gate'),
                      ),
                    ],
                  ),
                ),

              // Message List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: widget.chatViewModel.messages.length,
                  itemBuilder: (context, idx) {
                    final msg = widget.chatViewModel.messages[idx];
                    final isHuman = msg.role == 'human';
                    final timeStr = DateFormat('HH:mm:ss').format(msg.timestamp);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isHuman ? AcrColors.cyan.withValues(alpha: 0.2) : AcrColors.card,
                            child: Text(
                              msg.sender.substring(0, 1),
                              style: TextStyle(
                                color: isHuman ? AcrColors.cyan : AcrColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      msg.sender,
                                      style: TextStyle(
                                        color: isHuman ? AcrColors.cyan : AcrColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isHuman
                                            ? AcrColors.cyan.withValues(alpha: 0.15)
                                            : AcrColors.indigo.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        msg.role.toUpperCase(),
                                        style: TextStyle(
                                          color: isHuman ? AcrColors.cyan : AcrColors.indigo,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      timeStr,
                                      style: const TextStyle(color: AcrColors.textMuted, fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.content,
                                  style: const TextStyle(color: AcrColors.textSecondary, fontSize: 13, height: 1.4),
                                ),
                                if (msg.toolCall != null) McpToolCard(toolCall: msg.toolCall!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Compose Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: AcrColors.surface,
                  border: Border(top: BorderSide(color: AcrColors.cardBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AcrColors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AcrColors.cardBorder),
                        ),
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(color: AcrColors.textPrimary, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Inject human operator directive into consensus stream...',
                            hintStyle: TextStyle(color: AcrColors.textMuted, fontSize: 12),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _handleSend(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AcrColors.cyan),
                      onPressed: _handleSend,
                      tooltip: 'Send directive',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
