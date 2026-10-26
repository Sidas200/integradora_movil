import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:integradora_movil/core/network/api_client.dart';
import 'package:integradora_movil/core/network/api_exception.dart';
import 'package:integradora_movil/core/storage/token_storage.dart';
import 'package:integradora_movil/data/repositories/auth_repository.dart';
import 'package:integradora_movil/data/repositories/game_repository.dart';

/// Almacenamiento en memoria para pruebas.
class MemoryTokenStorage extends TokenStorage {
  String? access;
  String? refresh;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> save({required String accessToken, String? refreshToken}) async {
    access = accessToken;
    if (refreshToken != null) refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

const _base = 'http://api.test/api/v1';

Map<String, dynamic> _tokens(String access, String refresh) => {
  'accessToken': access,
  'tokenType': 'Bearer',
  'expiresInSec': 900,
  'refreshToken': refresh,
  'player': {
    'id': '6f1c2a7e-0b7d-4e7a-9a0e-3d1f5b2c9e11',
    'username': 'Felc',
    'email': 'felc@example.com',
  },
};

const _account = {
  'id': '6f1c2a7e-0b7d-4e7a-9a0e-3d1f5b2c9e11',
  'username': 'Felc',
  'email': 'felc@example.com',
  'createdAt': '2026-10-01T18:20:00Z',
  'lastLoginAt': null,
  'summary': {
    'saves': 2,
    'playTimeSec': 11520,
    'enemiesDefeated': 148,
    'itemsCrafted': 9,
    'achievementsUnlocked': 2,
    'achievementsTotal': 6,
    'lastSessionAt': null,
  },
};

http.Response _json(Object body, int status) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test('login envía client MOBILE y guarda los tokens', () async {
    late Map<String, dynamic> sent;
    final storage = MemoryTokenStorage();
    final api = ApiClient(
      tokenStorage: storage,
      baseUrl: _base,
      httpClient: MockClient((req) async {
        expect(req.url.toString(), '$_base/auth/login');
        sent = jsonDecode(req.body) as Map<String, dynamic>;
        return _json(_tokens('a1', 'r1'), 200);
      }),
    );

    final player = await AuthRepository(
      api: api,
      tokens: storage,
    ).login(email: 'felc@example.com', password: 'secret123');

    expect(sent['client'], 'MOBILE');
    expect(player.username, 'Felc');
    expect(storage.access, 'a1');
    expect(storage.refresh, 'r1');
  });

  test('credenciales inválidas se convierten en ApiException', () async {
    final storage = MemoryTokenStorage();
    final api = ApiClient(
      tokenStorage: storage,
      baseUrl: _base,
      httpClient: MockClient(
        (_) async => _json({
          'type': 'x',
          'title': 'Unauthenticated',
          'status': 401,
          'code': 'INVALID_CREDENTIALS',
        }, 401),
      ),
    );

    expect(
      () => AuthRepository(
        api: api,
        tokens: storage,
      ).login(email: 'a@b.c', password: 'x'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', 'INVALID_CREDENTIALS')
            .having(
              (e) => e.userMessage,
              'msg',
              'Correo o contraseña incorrectos.',
            ),
      ),
    );
  });

  test('con 401 renueva el token y repite la petición', () async {
    final storage = MemoryTokenStorage()
      ..access = 'old'
      ..refresh = 'r-old';
    final calls = <String>[];
    final api = ApiClient(
      tokenStorage: storage,
      baseUrl: _base,
      httpClient: MockClient((req) async {
        calls.add(
          '${req.method} ${req.url.path} ${req.headers['Authorization'] ?? ''}',
        );
        if (req.url.path.endsWith('/auth/refresh')) {
          expect(jsonDecode(req.body), {'refreshToken': 'r-old'});
          return _json(_tokens('new', 'r-new'), 200);
        }
        if (req.headers['Authorization'] == 'Bearer old') {
          return _json({
            'type': 'x',
            'title': 'x',
            'status': 401,
            'code': 'TOKEN_EXPIRED',
          }, 401);
        }
        return _json(_account, 200);
      }),
    );

    final account = await GameRepository(api: api).getAccount();

    expect(account.summary.enemiesDefeated, 148);
    expect(storage.access, 'new');
    expect(storage.refresh, 'r-new');
    expect(calls, [
      'GET /api/v1/account Bearer old',
      'POST /api/v1/auth/refresh ',
      'GET /api/v1/account Bearer new',
    ]);
  });

  test('si el refresh falla avisa que la sesión expiró', () async {
    var expired = false;
    final storage = MemoryTokenStorage()
      ..access = 'old'
      ..refresh = 'r-old';
    final api = ApiClient(
      tokenStorage: storage,
      baseUrl: _base,
      httpClient: MockClient(
        (_) async => _json({
          'type': 'x',
          'title': 'x',
          'status': 401,
          'code': 'INVALID_SESSION',
        }, 401),
      ),
    )..onSessionExpired = () => expired = true;

    await expectLater(
      GameRepository(api: api).getAccount(),
      throwsA(isA<ApiException>()),
    );
    expect(expired, isTrue);
  });

  test('parsea logros y noticias del contrato', () async {
    final api = ApiClient(
      tokenStorage: MemoryTokenStorage()..access = 'a',
      baseUrl: _base,
      httpClient: MockClient((req) async {
        if (req.url.path.endsWith('/account/achievements')) {
          return _json([
            {
              'id': 'b',
              'name': '???',
              'description': null,
              'iconKey': null,
              'hidden': true,
              'sortOrder': 30,
              'unlocked': false,
              'unlockedAt': null,
            },
            {
              'id': 'first_craft',
              'name': 'El poder se fabrica',
              'description': 'Fabrica tu primer objeto.',
              'iconKey': 'x',
              'hidden': false,
              'sortOrder': 20,
              'unlocked': true,
              'unlockedAt': '2026-10-10T01:53:00Z',
            },
          ], 200);
        }
        expect(req.headers.containsKey('Authorization'), isFalse);
        expect(req.url.queryParameters, {'page': '0', 'size': '20'});
        return _json({
          'content': [
            {
              'slug': 'hola',
              'title': 'Hola',
              'summary': 'Resumen',
              'coverKey': null,
              'publishedAt': '2026-10-01T00:00:00Z',
            },
          ],
          'page': {
            'number': 0,
            'size': 20,
            'totalElements': 1,
            'totalPages': 1,
          },
        }, 200);
      }),
    );
    final repo = GameRepository(api: api);

    final achievements = await repo.getMyAchievements();
    expect(achievements.first.id, 'first_craft');
    expect(achievements.first.unlocked, isTrue);

    final news = await repo.getNews();
    expect(news.content.single.slug, 'hola');
    expect(news.hasMore, isFalse);
  });
}
