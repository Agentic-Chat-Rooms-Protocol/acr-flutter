import 'package:flutter/foundation.dart';
import '../../../../domain/models/audit_entry.dart';
import '../../../../domain/use_cases/get_audit_trail_use_case.dart';

class AuditViewModel extends ChangeNotifier {
  AuditViewModel({required this.getAuditTrailUseCase});

  final GetAuditTrailUseCase getAuditTrailUseCase;

  List<AuditEntry> _auditLogs = [];
  List<AuditEntry> get auditLogs => _auditLogs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadAuditLogs({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _auditLogs = await getAuditTrailUseCase.execute(forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
