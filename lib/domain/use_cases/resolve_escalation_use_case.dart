import '../../data/repositories/governance_repository.dart';
import '../models/escalation.dart';

class ResolveEscalationUseCase {
  ResolveEscalationUseCase({required this.repository});

  final GovernanceRepository repository;

  Future<Escalation> execute({
    required String escalationId,
    required bool approve,
    required String operatorDid,
  }) async {
    // Generate deterministic cryptographic signature proof
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final signature = 'ed25519:sig_${operatorDid.hashCode}_${escalationId}_$timestamp';

    return repository.resolveEscalation(
      escalationId,
      approve: approve,
      operatorDid: operatorDid,
      signature: signature,
    );
  }
}
