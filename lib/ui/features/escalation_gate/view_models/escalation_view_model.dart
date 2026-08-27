import 'package:flutter/foundation.dart';
import '../../../../data/repositories/governance_repository.dart';
import '../../../../domain/models/escalation.dart';
import '../../../../domain/use_cases/resolve_escalation_use_case.dart';

class EscalationViewModel extends ChangeNotifier {
  EscalationViewModel({
    required this.governanceRepository,
    required this.resolveEscalationUseCase,
  });

  final GovernanceRepository governanceRepository;
  final ResolveEscalationUseCase resolveEscalationUseCase;

  List<Escalation> _escalations = [];
  List<Escalation> get pendingEscalations =>
      _escalations.where((e) => e.status == EscalationStatus.pending).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadEscalations({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _escalations = await governanceRepository.getEscalations(forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resolve({
    required String escalationId,
    required bool approve,
    required String operatorDid,
  }) async {
    try {
      final resolved = await resolveEscalationUseCase.execute(
        escalationId: escalationId,
        approve: approve,
        operatorDid: operatorDid,
      );
      _escalations = _escalations.map((e) => e.id == escalationId ? resolved : e).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
