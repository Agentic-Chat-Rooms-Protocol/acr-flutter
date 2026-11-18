import 'package:flutter/material.dart';

import '../../../core/theme/acr_theme.dart';

class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({super.key, required this.onCreate});

  final Future<void> Function({
    required String name,
    required String description,
    required String topic,
    required bool isPrivate,
  })
  onCreate;

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _topicController = TextEditingController();
  bool _isPrivate = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.onCreate(
        name: name,
        description: _descController.text.trim(),
        topic: _topicController.text.trim().isEmpty
            ? 'General Deliberation'
            : _topicController.text.trim(),
        isPrivate: _isPrivate,
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AcrColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AcrColors.cardBorder),
      ),
      title: const Row(
        children: [
          Icon(Icons.tag, color: AcrColors.zyphraOrange, size: 20),
          SizedBox(width: 8),
          Text(
            'Create Deliberation Room',
            style: TextStyle(
              color: AcrColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Room Name',
              style: TextStyle(color: AcrColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              style: const TextStyle(
                color: AcrColors.textPrimary,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Canary Deployment Floor',
                hintStyle: const TextStyle(color: AcrColors.textMuted),
                filled: true,
                fillColor: AcrColors.cardOverlay,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AcrColors.cardBorder),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Topic',
              style: TextStyle(color: AcrColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _topicController,
              style: const TextStyle(
                color: AcrColors.textPrimary,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. W3C DID • AST Diff Verification',
                hintStyle: const TextStyle(color: AcrColors.textMuted),
                filled: true,
                fillColor: AcrColors.cardOverlay,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AcrColors.cardBorder),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Description',
              style: TextStyle(color: AcrColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _descController,
              maxLines: 2,
              style: const TextStyle(
                color: AcrColors.textPrimary,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Deliberation scope and tool governance rules...',
                hintStyle: const TextStyle(color: AcrColors.textMuted),
                filled: true,
                fillColor: AcrColors.cardOverlay,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AcrColors.cardBorder),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AcrColors.cardOverlay,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AcrColors.subtleBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    _isPrivate ? Icons.lock : Icons.shield_outlined,
                    color: _isPrivate
                        ? AcrColors.amber
                        : AcrColors.zyphraOrange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Private Channel (ACL)',
                          style: TextStyle(
                            color: AcrColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Only invited participants can view/send',
                          style: TextStyle(
                            color: AcrColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPrivate,
                    onChanged: (val) => setState(() => _isPrivate = val),
                    activeThumbColor: AcrColors.zyphraOrange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AcrColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AcrColors.zyphraOrange,
            foregroundColor: AcrColors.textOnAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _isSubmitting ? 'Creating...' : 'Create Room',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
