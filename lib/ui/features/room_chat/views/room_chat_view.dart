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
      listenable: Listenable.merge([
        widget.chatViewModel,
        widget.escalationViewModel,
      ]),
      builder: (context, _) {
        final room = widget.chatViewModel.selectedRoom;
        final pendingEscalations =
            widget.escalationViewModel.pendingEscalations;

        if (widget.chatViewModel.isLoading && room == null) {
          return const Center(
            child: CircularProgressIndicator(color: AcrColors.zyphraOrange),
          );
        }

        return Container(
          color: AcrColors.background,
          child: Column(
            children: [
              // Room Header
              if (room != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AcrColors.surface,
                    border: Border(
                      bottom: BorderSide(color: AcrColors.subtleBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tag,
                        color: AcrColors.zyphraOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          room.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AcrColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AcrColors.cardOverlay,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AcrColors.subtleBorder),
                          ),
                          child: Text(
                            room.topic,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AcrColors.textMuted,
                              fontSize: 10,
                              fontFamily: AcrTypography.monoFontFamily,
                              fontFamilyFallback: AcrTypography.monoFallback,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: AcrColors.textSecondary,
                          size: 18,
                        ),
                        onPressed: () {
                          widget.chatViewModel.loadMessages(
                            room.id,
                            forceRefresh: true,
                          );
                          widget.escalationViewModel.loadEscalations(
                            forceRefresh: true,
                          );
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AcrColors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AcrColors.amber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AcrColors.amber,
                        size: 20,
                      ),
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
                              style: const TextStyle(
                                color: AcrColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog<void>(
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
                          backgroundColor: AcrColors.zyphraOrange,
                          foregroundColor: AcrColors.textOnAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: widget.chatViewModel.messages.length,
                  itemBuilder: (context, idx) {
                    final msg = widget.chatViewModel.messages[idx];
                    final isHuman = msg.role == 'human';
                    final timeStr = DateFormat('HH:mm:ss')
                        .format(msg.timestamp);
                    final initial = msg.sender.isNotEmpty
                        ? msg.sender.substring(0, 1)
                        : '?';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isHuman
                                ? AcrColors.zyphraOrange.withValues(alpha: 0.2)
                                : AcrColors.cardOverlay,
                            child: Text(
                              initial,
                              style: TextStyle(
                                color: isHuman
                                    ? AcrColors.solarTint
                                    : AcrColors.textSecondary,
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
                                    Flexible(
                                      child: Text(
                                        msg.sender,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isHuman
                                              ? AcrColors.solarTint
                                              : AcrColors.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isHuman
                                            ? AcrColors.zyphraOrange.withValues(
                                                alpha: 0.16,
                                              )
                                            : AcrColors.graphite,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        msg.role.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily:
                                              AcrTypography.monoFontFamily,
                                          fontFamilyFallback:
                                              AcrTypography.monoFallback,
                                          color: isHuman
                                              ? AcrColors.solarTint
                                              : AcrColors.textSecondary,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      timeStr,
                                      style: const TextStyle(
                                        fontFamily:
                                            AcrTypography.monoFontFamily,
                                        fontFamilyFallback:
                                            AcrTypography.monoFallback,
                                        color: AcrColors.textMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.content,
                                  style: const TextStyle(
                                    color: AcrColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                if (msg.toolCall != null)
                                  McpToolCard(toolCall: msg.toolCall!),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: AcrColors.surface,
                  border: Border(
                    top: BorderSide(color: AcrColors.subtleBorder),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AcrColors.cardOverlay,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AcrColors.cardBorder),
                        ),
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(
                            color: AcrColors.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            filled: false,
                            hintText: 'Inject human operator directive into consensus stream...',
                            hintStyle: TextStyle(
                              color: AcrColors.textMuted,
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onSubmitted: (_) => _handleSend(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: AcrColors.zyphraOrange,
                      ),
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
