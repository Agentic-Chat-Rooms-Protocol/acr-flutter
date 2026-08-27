import 'package:flutter_test/flutter_test.dart';
import 'package:acr_flutter/data/repositories/room_repository.dart';
import 'package:acr_flutter/data/services/acr_gateway_service.dart';
import 'package:acr_flutter/domain/use_cases/send_message_use_case.dart';

void main() {
  group('Domain Use Cases', () {
    test('SendMessageUseCase rejects empty content', () async {
      final gateway = AcrGatewayService();
      final roomRepo = RoomRepository(gatewayService: gateway);
      final useCase = SendMessageUseCase(repository: roomRepo);

      expect(
        () => useCase.execute(
          roomId: 'consensus-main',
          senderDid: 'did:key:test',
          content: '   ',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
