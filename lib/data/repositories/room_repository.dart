import '../../domain/models/message.dart';
import '../../domain/models/room.dart';
import '../services/acr_gateway_service.dart';

class RoomRepository {
  RoomRepository({required this.gatewayService});

  final AcrGatewayService gatewayService;
  List<Room> _cachedRooms = [];
  final Map<String, List<Message>> _cachedMessages = {};

  List<Room> get cachedRooms => List.unmodifiable(_cachedRooms);

  Future<List<Room>> getRooms({bool forceRefresh = false}) async {
    if (_cachedRooms.isNotEmpty && !forceRefresh) {
      return _cachedRooms;
    }

    _cachedRooms = await gatewayService.fetchRooms();
    return _cachedRooms;
  }

  Future<List<Message>> getMessages(String roomId, {bool forceRefresh = false}) async {
    if (_cachedMessages.containsKey(roomId) && !forceRefresh) {
      return _cachedMessages[roomId]!;
    }

    final msgs = await gatewayService.fetchMessages(roomId);
    _cachedMessages[roomId] = msgs;
    return msgs;
  }

  Future<Message> sendMessage(String roomId, String senderDid, String content) async {
    final msg = await gatewayService.sendMessage(
      roomId: roomId,
      senderDid: senderDid,
      content: content,
    );

    if (!_cachedMessages.containsKey(roomId)) {
      _cachedMessages[roomId] = [];
    }
    _cachedMessages[roomId]!.add(msg);
    return msg;
  }
}
