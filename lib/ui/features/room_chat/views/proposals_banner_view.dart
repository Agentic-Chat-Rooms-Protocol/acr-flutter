import 'package:flutter/material.dart';

import '../../../../domain/models/proposal.dart';
import '../../../core/theme/acr_theme.dart';

class ProposalsBannerView extends StatelessWidget {
  const ProposalsBannerView({
    super.key,
    required this.proposals,
    required this.currentVoterDid,
    required this.onVote,
  });

  final List<Proposal> proposals;
  final String currentVoterDid;
  final Future<void> Function(
    String proposalId,
    String choice, {
    String? rationale,
  })
  onVote;

  void _promptDissent(BuildContext context, Proposal prop) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _DissentRationaleDialog(
        onSubmit: (rationale) =>
            onVote(prop.id, 'DISSENT', rationale: rationale),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final openList = proposals.where((p) => p.isOpen).toList();
    if (openList.isEmpty) return const SizedBox.shrink();

    final prop = openList.first;
    final userVote = prop.votes[currentVoterDid];

    int approves = 0;
    int rejects = 0;
    int dissents = 0;
    for (final v in prop.votes.values) {
      final u = v.toUpperCase();
      if (u == 'APPROVE' || u == 'YES') approves++;
      if (u == 'REJECT' || u == 'NO') rejects++;
      if (u == 'DISSENT') dissents++;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AcrColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AcrColors.amber.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AcrColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AcrColors.amber.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.how_to_vote,
                      color: AcrColors.amber,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      prop.id.toUpperCase(),
                      style: const TextStyle(
                        color: AcrColors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: AcrTypography.monoFontFamily,
                        fontFamilyFallback: AcrTypography.monoFallback,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  prop.title,
                  style: const TextStyle(
                    color: AcrColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${prop.votes.length} Votes',
                style: const TextStyle(
                  color: AcrColors.textMuted,
                  fontSize: 10,
                  fontFamily: AcrTypography.monoFontFamily,
                  fontFamilyFallback: AcrTypography.monoFallback,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            prop.description,
            style: const TextStyle(
              color: AcrColors.textSecondary,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Tally summary
          Row(
            children: [
              Text(
                'Approve: $approves',
                style: const TextStyle(
                  color: AcrColors.emerald,
                  fontSize: 10,
                  fontFamily: AcrTypography.monoFontFamily,
                  fontFamilyFallback: AcrTypography.monoFallback,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Reject: $rejects',
                style: const TextStyle(
                  color: AcrColors.rose,
                  fontSize: 10,
                  fontFamily: AcrTypography.monoFontFamily,
                  fontFamilyFallback: AcrTypography.monoFallback,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Dissent: $dissents',
                style: const TextStyle(
                  color: AcrColors.amber,
                  fontSize: 10,
                  fontFamily: AcrTypography.monoFontFamily,
                  fontFamilyFallback: AcrTypography.monoFallback,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Voting Buttons or User Vote Status
          if (userVote != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AcrColors.zyphraOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AcrColors.zyphraOrange.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AcrColors.solarTint,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Your ballot recorded: $userVote',
                    style: const TextStyle(
                      color: AcrColors.solarTint,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onVote(prop.id, 'APPROVE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AcrColors.emerald,
                      side: const BorderSide(color: AcrColors.emerald),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onVote(prop.id, 'REJECT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AcrColors.rose,
                      side: const BorderSide(color: AcrColors.rose),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Reject', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _promptDissent(context, prop),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AcrColors.amber,
                      side: const BorderSide(color: AcrColors.amber),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Dissent...',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DissentRationaleDialog extends StatefulWidget {
  const _DissentRationaleDialog({required this.onSubmit});

  final Future<void> Function(String rationale) onSubmit;

  @override
  State<_DissentRationaleDialog> createState() =>
      _DissentRationaleDialogState();
}

class _DissentRationaleDialogState extends State<_DissentRationaleDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AcrColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AcrColors.amber),
      ),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AcrColors.amber, size: 20),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Preserve Dissent Rationale',
              style: TextStyle(
                color: AcrColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dissenting arguments are anchored permanently into the TLA+ verified SHA-256 state chain.',
            style: TextStyle(color: AcrColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            style: const TextStyle(color: AcrColors.textPrimary, fontSize: 12),
            decoration: InputDecoration(
              hintText:
                  'Enter architectural or safety justification for dissent...',
              hintStyle: const TextStyle(color: AcrColors.textMuted),
              filled: true,
              fillColor: AcrColors.cardOverlay,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AcrColors.cardBorder),
              ),
            ),
          ),
        ],
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
          onPressed: () async {
            final text = _controller.text.trim();
            if (text.isEmpty) return;
            Navigator.of(context).pop();
            await widget.onSubmit(text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AcrColors.amber,
            foregroundColor: AcrColors.textOnAccent,
          ),
          child: const Text(
            'Anchor Dissent',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
