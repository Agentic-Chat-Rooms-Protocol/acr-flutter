import '../../domain/models/audit_entry.dart';
import '../../domain/models/escalation.dart';
import '../services/acr_gateway_service.dart';

class GovernanceRepository {
  GovernanceRepository({required this.gatewayService});

  final AcrGatewayService gatewayService;
  List<Escalation> _cachedEscalations = [];
  List<AuditEntry> _cachedAuditLogs = [];

  List<Escalation> get cachedEscalations => List.unmodifiable(_cachedEscalations);
  List<AuditEntry> get cachedAuditLogs => List.unmodifiable(_cachedAuditLogs);

  Future<List<Escalation>> getEscalations({bool forceRefresh = false}) async {
    if (_cachedEscalations.isNotEmpty && !forceRefresh) {
      return _cachedEscalations;
    }

    _cachedEscalations = await gatewayService.fetchEscalations();
    return _cachedEscalations;
  }

  Future<Escalation> resolveEscalation(
    String id, {
    required bool approve,
    required String operatorDid,
    required String signature,
  }) async {
    final resolved = await gatewayService.resolveEscalation(
      escalationId: id,
      approve: approve,
      operatorDid: operatorDid,
      signature: signature,
    );

    _cachedEscalations = _cachedEscalations.map((e) => e.id == id ? resolved : e).toList();
    return resolved;
  }

  Future<List<AuditEntry>> getAuditLogs({bool forceRefresh = false}) async {
    if (_cachedAuditLogs.isNotEmpty && !forceRefresh) {
      return _cachedAuditLogs;
    }

    _cachedAuditLogs = await gatewayService.fetchAuditLogs();
    return _cachedAuditLogs;
  }
}
