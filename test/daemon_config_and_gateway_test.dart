import 'dart:convert';
import 'dart:io';

import 'package:acr_flutter/data/services/acr_gateway_service.dart';
import 'package:acr_flutter/data/services/daemon_config_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../bin/acr.dart' as acr_cli;

void main() {
  group('Daemon Config Resolution', () {
    test('defaults to literal 127.0.0.1:20443 (never localhost)', () {
      expect(kDefaultDaemonUrl, 'http://127.0.0.1:20443');
      expect(kDefaultDaemonUrl.contains('localhost'), isFalse);
      expect(
        resolveDefaultDaemonUrl(environment: const {}),
        'http://127.0.0.1:20443',
      );
      expect(
        resolveDefaultDaemonUrl(environment: {'ACR_DAEMON_URL': '   '}),
        'http://127.0.0.1:20443',
      );
    });

    test('normalizes ACR_DAEMON_URL whitespace and trailing slashes', () {
      expect(
        resolveDefaultDaemonUrl(
          environment: {'ACR_DAEMON_URL': ' http://127.0.0.1:29999/// '},
        ),
        'http://127.0.0.1:29999',
      );
    });

    test('prefers ACR_API_TOKEN env var over ~/.acr/api-token file', () {
      final tempHome = Directory.systemTemp.createTempSync('acr_token_prec_');
      addTearDown(() => tempHome.deleteSync(recursive: true));

      final acrDir = Directory('${tempHome.path}${Platform.pathSeparator}.acr')
        ..createSync(recursive: true);
      File('${acrDir.path}${Platform.pathSeparator}api-token')
          .writeAsStringSync('file-token-abc\n');

      expect(
        resolveDaemonApiToken(
          environment: {'ACR_API_TOKEN': '  env-token-xyz  '},
          homeDirectory: tempHome.path,
        ),
        'env-token-xyz',
      );

      expect(
        resolveDaemonApiToken(
          environment: {'ACR_API_TOKEN': '   '},
          homeDirectory: tempHome.path,
        ),
        'file-token-abc',
      );
    });

    test('loads ~/.acr/api-token via HOME or USERPROFILE fallback', () {
      final tempHome = Directory.systemTemp.createTempSync('acr_token_home_');
      addTearDown(() => tempHome.deleteSync(recursive: true));

      final acrDir = Directory('${tempHome.path}${Platform.pathSeparator}.acr')
        ..createSync(recursive: true);
      File('${acrDir.path}${Platform.pathSeparator}api-token')
          .writeAsStringSync('  disk-token-123\r\n');

      expect(
        resolveDaemonApiToken(
          environment: {'HOME': '', 'USERPROFILE': tempHome.path},
        ),
        'disk-token-123',
      );
    });

    test('returns null when token file is missing, empty, or malformed', () {
      final tempHome = Directory.systemTemp.createTempSync('acr_token_bad_');
      addTearDown(() => tempHome.deleteSync(recursive: true));

      expect(
        resolveDaemonApiToken(
          environment: const {},
          homeDirectory: tempHome.path,
        ),
        isNull,
      );

      final acrDir = Directory('${tempHome.path}${Platform.pathSeparator}.acr')
        ..createSync(recursive: true);
      final tokenFile = File('${acrDir.path}${Platform.pathSeparator}api-token')
        ..writeAsStringSync('   \n');

      expect(
        resolveDaemonApiToken(
          environment: const {},
          homeDirectory: tempHome.path,
        ),
        isNull,
      );

      tokenFile.writeAsBytesSync([0xFF, 0xFE, 0xFD]);
      expect(
        resolveDaemonApiToken(
          environment: const {},
          homeDirectory: tempHome.path,
        ),
        isNull,
      );
    });
  });

  group('AcrGatewayService HTTP & Bearer Auth Contract', () {
    test('uses 127.0.0.1:20443 and sends Bearer token on GET/POST', () async {
      final recorded = <http.Request>[];
      final mockClient = MockClient((req) async {
        recorded.add(req);
        return switch (req.url.path) {
          '/api/v1/rooms' when req.method == 'GET' => http.Response(
            jsonEncode([
              {
                'id': 'room/1',
                'name': 'Main',
                'description': 'Desc',
                'topic': 'Topic',
                'is_private': false,
                'participants': <String>[],
                'created_at': '2026-11-18T12:00:00Z',
                'message_count': 1,
              },
            ]),
            200,
          ),
          '/api/v1/rooms' when req.method == 'POST' => http.Response(
            jsonEncode({
              'id': 'room-2',
              'name': 'New',
              'description': 'Desc',
              'topic': 'Topic',
              'is_private': true,
              'participants': <String>[],
              'created_at': '2026-11-18T12:00:00Z',
              'message_count': 0,
            }),
            201,
          ),
          '/api/v1/rooms/room%2F1/messages' when req.method == 'POST' =>
            http.Response(
              jsonEncode({
                'id': 'm1',
                'room_id': 'room/1',
                'sender_did': 'did:key:op',
                'content': 'hello',
                'timestamp': '2026-11-18T12:00:00Z',
              }),
              201,
            ),
          '/api/v1/proposals/prop%2F1/vote' => http.Response(
            jsonEncode({
              'id': 'prop/1',
              'room_id': 'room/1',
              'title': 'CIP',
              'description': 'Desc',
              'proposer_did': 'did:key:op',
              'options': ['APPROVE', 'REJECT', 'DISSENT'],
              'votes': {'did:key:op': 'DISSENT'},
              'dissent_logs': <Map<String, dynamic>>[],
              'status': 'open',
              'created_at': '2026-11-18T12:00:00Z',
            }),
            200,
          ),
          '/api/v1/escalations/esc%2F1/resolve' => http.Response(
            jsonEncode({
              'id': 'esc/1',
              'requesting_did': 'did:key:a',
              'action': 'deploy',
              'status': 'approved',
              'created_at': '2026-11-18T12:00:00Z',
            }),
            200,
          ),
          _ => http.Response('[]', 200),
        };
      });

      final service = AcrGatewayService(
        client: mockClient,
        environment: {'ACR_API_TOKEN': 'secret-bearer-token'},
        homeDirectory: '',
      );

      expect(service.baseUrl, 'http://127.0.0.1:20443');

      await service.fetchRooms();
      await service.createRoom(
        name: 'New',
        description: 'Desc',
        topic: 'Topic',
        isPrivate: true,
        creatorDid: 'did:key:op',
      );
      await service.sendMessage(
        roomId: 'room/1',
        senderDid: 'did:key:op',
        content: 'hello',
      );
      await service.castVote(
        proposalId: 'prop/1',
        voterDid: 'did:key:op',
        choice: 'DISSENT',
        rationale: 'Needs guard',
      );
      await service.resolveEscalation(
        escalationId: 'esc/1',
        approve: true,
        operatorDid: 'did:key:op',
        signature: 'ed25519:sig',
      );
      await service.fetchAuditLogs();

      expect(recorded.length, 6);
      for (final req in recorded) {
        expect(req.url.host, '127.0.0.1');
        expect(req.url.port, 20443);
        expect(req.headers['Authorization'], 'Bearer secret-bearer-token');
      }
      expect(recorded[1].headers['Content-Type'], 'application/json');
      expect(recorded[2].url.path, '/api/v1/rooms/room%2F1/messages');
      expect(recorded[3].url.path, '/api/v1/proposals/prop%2F1/vote');
      expect(
        jsonDecode(recorded[3].body) as Map<String, dynamic>,
        containsPair('rationale', 'Needs guard'),
      );
      expect(recorded[4].url.path, '/api/v1/escalations/esc%2F1/resolve');
    });

    test(
      'omits Authorization header when no token configured & throws on 401',
      () async {
        final recorded = <http.Request>[];
        final mockClient = MockClient((req) async {
          recorded.add(req);
          return http.Response('Unauthorized', 401);
        });

        final service = AcrGatewayService(
          baseUrl: 'http://127.0.0.1:20443///',
          client: mockClient,
          environment: const {},
          homeDirectory: '',
        );

        expect(service.baseUrl, 'http://127.0.0.1:20443');
        await expectLater(service.fetchAgents(), throwsException);
        expect(recorded.single.headers.containsKey('Authorization'), isFalse);
      },
    );
  });

  group('ACR CLI (bin/acr.dart)', () {
    test(
      'buildDaemonHeaders prioritizes explicit token then env then file',
      () {
        final tempHome = Directory.systemTemp.createTempSync('acr_cli_tok_');
        addTearDown(() => tempHome.deleteSync(recursive: true));

        final acrDir = Directory(
          '${tempHome.path}${Platform.pathSeparator}.acr',
        )..createSync(recursive: true);
        File('${acrDir.path}${Platform.pathSeparator}api-token')
            .writeAsStringSync('file-cli-token');

        expect(
          acr_cli.buildDaemonHeaders(
            token: 'explicit-cli',
            jsonContent: true,
            environment: {'ACR_API_TOKEN': 'env-cli'},
            homeDirectory: tempHome.path,
          ),
          {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer explicit-cli',
          },
        );

        expect(
          acr_cli.buildDaemonHeaders(
            environment: {'ACR_API_TOKEN': 'env-cli'},
            homeDirectory: tempHome.path,
          ),
          {'Authorization': 'Bearer env-cli'},
        );

        expect(
          acr_cli.buildDaemonHeaders(
            environment: const {},
            homeDirectory: tempHome.path,
          ),
          {'Authorization': 'Bearer file-cli-token'},
        );

        expect(
          acr_cli.buildDaemonHeaders(environment: const {}, homeDirectory: ''),
          isEmpty,
        );
      },
    );

    test('status, rooms, escalations, approve, and audit use 127.0.0.1:20443 and Bearer auth', () async {
      final requests = <http.Request>[];
      final mockClient = MockClient((req) async {
        requests.add(req);
        return switch (req.url.path) {
          '/api/v1/rooms' => http.Response(
            jsonEncode([
              {
                'id': 'consensus-main',
                'name': 'Main',
                'topic': 'W3C DID',
                'message_count': 3,
              },
            ]),
            200,
          ),
          '/api/v1/agents' => http.Response(
            jsonEncode([
              {'did': 'did:key:1'},
            ]),
            200,
          ),
          '/api/v1/escalations' => http.Response(
            jsonEncode([
              {
                'id': 'esc-1',
                'risk_level': 'HIGH',
                'agent_name': 'Sentinel',
                'action': 'k8s.deploy',
                'payload': '{}',
                'status': 'pending',
              },
            ]),
            200,
          ),
          '/api/v1/escalations/esc-1/resolve' => http.Response('{}', 200),
          '/api/v1/audit' => http.Response(
            jsonEncode([
              {
                'index': 0,
                'event_type': 'GENESIS',
                'state_hash': 'abc',
                'previous_hash': '000',
                'timestamp': '2026-11-18T12:00:00Z',
              },
            ]),
            200,
          ),
          _ => http.Response('Not Found', 404),
        };
      });

      final out = StringBuffer();
      final err = StringBuffer();
      int? exitCode;

      final runner = acr_cli.createAcrCommandRunner(
        client: mockClient,
        out: out,
        err: err,
        exitFn: (code) => exitCode = code,
        environment: {'ACR_API_TOKEN': 'cli-env-tok'},
        homeDirectory: '',
      );

      await runner.run(['status']);
      await runner.run(['rooms']);
      await runner.run(['escalations']);
      await runner.run(['approve', '--id', 'esc-1']);
      await runner.run(['audit']);

      expect(exitCode, isNull);
      expect(err.toString(), isEmpty);
      expect(out.toString(), contains('Active Deliberation Rooms: 1'));
      expect(out.toString(), contains('ACTIVE ACR ROOMS:'));
      expect(out.toString(), contains('PENDING HUMAN GATES:'));
      expect(
        out.toString(),
        contains('Escalation [esc-1] successfully approved'),
      );
      expect(
        out.toString(),
        contains('ACR CRYPTOGRAPHIC AUDIT LOG (1 BLOCKS):'),
      );

      expect(requests.length, 7);
      for (final req in requests) {
        expect(req.url.scheme, 'http');
        expect(req.url.host, '127.0.0.1');
        expect(req.url.port, 20443);
        expect(req.headers['Authorization'], 'Bearer cli-env-tok');
      }
    });

    test('CLI exits with code 1 when daemon returns non-200 status', () async {
      final mockClient = MockClient(
        (_) async => http.Response('Unauthorized', 401),
      );
      final out = StringBuffer();
      final err = StringBuffer();
      int? exitCode;

      final runner = acr_cli.createAcrCommandRunner(
        client: mockClient,
        out: out,
        err: err,
        exitFn: (code) => exitCode = code,
        environment: const {},
        homeDirectory: '',
      );

      await runner.run(['rooms']);

      expect(exitCode, 1);
      expect(err.toString(), contains('HTTP 401'));
    });
  });
}
