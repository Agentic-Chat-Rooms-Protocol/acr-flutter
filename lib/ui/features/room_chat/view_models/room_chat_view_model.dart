import 'package:flutter/foundation.dart';
import '../../../../data/repositories/room_repository.dart';
import '../../../../domain/models/message.dart';
import '../../../../domain/models/room.dart';
import '../../../../domain/use_cases/send_message_use_case.dart';

class RoomChatViewModel extends ChangeNotifier {
  RoomChatViewModel({
    required this.roomRepository,
    required this.sendMessageUseCase,
  });

  final RoomRepository roomRepository;
  final SendMessageUseCase sendMessageUseCase;

  List<Room> _rooms = [];
  List<Room> get rooms => _rooms;

  Room? _selectedRoom;
  Room? get selectedRoom => _selectedRoom;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSending = false;
  bool get isSending => _isSending;

  String? _error;
  String? get error => _error;

  Future<void> loadRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rooms = await roomRepository.getRooms();
      if (_rooms.isNotEmpty && _selectedRoom == null) {
        _selectedRoom = _rooms.first;
        await loadMessages(_selectedRoom!.id);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectRoom(Room room) async {
    if (_selectedRoom?.id == room.id) return;
    _selectedRoom = room;
    notifyListeners();
    await loadMessages(room.id);
  }

  Future<void> loadMessages(String roomId, {bool forceRefresh = false}) async {
    try {
      _messages = await roomRepository.getMessages(roomId, forceRefresh: forceRefresh);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content, {required String operatorDid}) async {
    if (_selectedRoom == null) return;
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    _isSending = true;
    notifyListeners();

    try {
      final newMsg = await sendMessageUseCase.execute(
        roomId: _selectedRoom!.id,
        senderDid: operatorDid,
        content: trimmed,
      );
      _messages = [..._messages, newMsg];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
