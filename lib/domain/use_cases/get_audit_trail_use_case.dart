import '../../data/repositories/governance_repository.dart';
import '../models/audit_entry.dart';

class GetAuditTrailUseCase {
  GetAuditTrailUseCase({required this.repository});

  final GovernanceRepository repository;

  Future<List<AuditEntry>> execute({bool forceRefresh = false}) async {
    return repository.getAuditLogs(forceRefresh: forceRefresh);
  }
}
