import 'package:flutter/foundation.dart';
import '../../../../data/repositories/agent_repository.dart';
import '../../../../domain/models/agent.dart';

class BuddyListViewModel extends ChangeNotifier {
  BuddyListViewModel({required this.agentRepository});

  final AgentRepository agentRepository;

  List<Agent> _agents = [];
  List<Agent> get agents => _agents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Agent> get autonomousAgents =>
      _agents.where((a) => a.role == 'agent' || a.role == 'sentinel').toList();

  List<Agent> get humanOperators =>
      _agents.where((a) => a.role == 'human').toList();

  Future<void> loadAgents({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _agents = await agentRepository.getAgents(forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
