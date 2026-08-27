import '../../domain/models/agent.dart';
import '../services/acr_gateway_service.dart';

class AgentRepository {
  AgentRepository({required this.gatewayService});

  final AcrGatewayService gatewayService;
  List<Agent> _cachedAgents = [];

  List<Agent> get cachedAgents => List.unmodifiable(_cachedAgents);

  Future<List<Agent>> getAgents({bool forceRefresh = false}) async {
    if (_cachedAgents.isNotEmpty && !forceRefresh) {
      return _cachedAgents;
    }

    _cachedAgents = await gatewayService.fetchAgents();
    return _cachedAgents;
  }
}
