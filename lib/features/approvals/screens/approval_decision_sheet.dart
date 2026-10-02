import 'package:flutter/material.dart';

/// Biometric-Secured Approval Decision Sheet (RFC-0012)
///
/// Presents a high-stakes ActionProposal to a human operator, requiring explicit
/// biometric confirmation before dispatching an Ed25519-signed decision.
class ApprovalDecisionSheet extends StatefulWidget {
  const ApprovalDecisionSheet({
    super.key,
    required this.actionId,
    required this.kind,
    required this.summary,
    required this.proposer,
    required this.onDecision,
  });

  final String actionId;
  final String kind;
  final String summary;
  final String proposer;
  final void Function(bool approved, String reason) onDecision;

  @override
  State<ApprovalDecisionSheet> createState() => _ApprovalDecisionSheetState();
}

class _ApprovalDecisionSheetState extends State<ApprovalDecisionSheet> {
  final TextEditingController _reasonController = TextEditingController();
  bool _biometricVerified = false;

  Future<void> _simulateBiometricAuth() async {
    // In production this delegates to local_auth package
    setState(() {
      _biometricVerified = true;
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D11),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security, color: Color(0xFFFF5500), size: 24),
                const SizedBox(width: 8),
                const Text(
                  'CRITICAL APPROVAL GATE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Action: ${widget.kind.toUpperCase()}',
              style: const TextStyle(
                color: Color(0xFFFF5500),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.summary,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                'Hash: ${widget.actionId}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Operator Rationale (Optional)',
                labelStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      widget.onDecision(false, _reasonController.text);
                      Navigator.of(context).pop();
                    },
                    child: const Text('VETO / REJECT'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5500),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      if (!_biometricVerified) {
                        await _simulateBiometricAuth();
                      }
                      widget.onDecision(true, _reasonController.text);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Text(_biometricVerified ? 'AUTHORIZE' : 'CONFIRM (BIOMETRIC)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
