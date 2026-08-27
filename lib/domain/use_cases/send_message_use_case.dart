import '../../data/repositories/room_repository.dart';
import '../models/message.dart';

class SendMessageUseCase {
  SendMessageUseCase({required this.repository});

  final RoomRepository repository;

  Future<Message> execute({
    required String roomId,
    required String senderDid,
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Message content cannot be empty');
    }
    return repository.sendMessage(roomId, senderDid, trimmed);
  }
}
