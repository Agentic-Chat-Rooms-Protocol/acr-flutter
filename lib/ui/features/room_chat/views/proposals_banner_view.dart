import 'package:flutter/material.dart';
import '../../../../domain/models/proposal.dart';

class ProposalsBannerView extends StatelessWidget {
  const ProposalsBannerView({
    super.key,
    required this.proposals,
    required this.currentVoterDid,
    required this.onVote,
  });

  final List<Proposal> proposals;
  final String currentVoterDid;
  final Future<void> Function(String proposalId, String choice, {String? rationale}) onVote;

  void _promptDissent(BuildContext context, Proposal prop) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF07080E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.amber),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Text(
              'Preserve Dissent Rationale',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dissenting arguments are anchored permanently into the TLA+ verified SHA-256 state chain.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Enter architectural or safety justification for dissent...',
                hintStyle: const TextStyle(color: Color(0xFF475569)),
                filled: true,
                fillColor: const Color(0xFF0B0F19),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(ctx).pop();
              await onVote(prop.id, 'DISSENT', rationale: text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('Anchor Dissent', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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
        color: const Color(0xFF0B0F19),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.how_to_vote, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      prop.id.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
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
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${prop.votes.length} Votes',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            prop.description,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Tally summary
          Row(
            children: [
              Text('Approve: $approves', style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontFamily: 'monospace')),
              const SizedBox(width: 12),
              Text('Reject: $rejects', style: const TextStyle(color: Color(0xFFF43F5E), fontSize: 10, fontFamily: 'monospace')),
              const SizedBox(width: 12),
              Text('Dissent: $dissents', style: const TextStyle(color: Colors.amber, fontSize: 10, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 8),

          // Voting Buttons or User Vote Status
          if (userVote != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF06B6D4), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Your ballot recorded: $userVote',
                    style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 11, fontWeight: FontWeight.bold),
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
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    child: const Text('Approve', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onVote(prop.id, 'REJECT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF43F5E),
                      side: const BorderSide(color: Color(0xFFF43F5E)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    child: const Text('Reject', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _promptDissent(context, prop),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber,
                      side: const BorderSide(color: Colors.amber),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    child: const Text('Dissent...', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
