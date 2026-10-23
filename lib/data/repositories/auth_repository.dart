import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../models/account.dart';
import '../models/session_player.dart';

/// Registro, inicio y cierre de sesión.
class AuthRepository {
  AuthRepository({required ApiClient api, required TokenStorage tokens})
      : _api = api,
        _tokens = tokens;

  final ApiClient _api;
  final TokenStorage _tokens;

  Future<SessionPlayer> login({required String email, required String password}) async {
    final json = await _api.post(
      '/auth/login',
      auth: false,
      body: {'email': email, 'password': password, 'client': ApiConfig.clientType},
    );
    return _saveSession(json as Map<String, dynamic>);
  }

  Future<SessionPlayer> register({
    required String email,
    required String username,
    required String password,
    required bool acceptedPrivacyNotice,
  }) async {
    final json = await _api.post(
      '/auth/register',
      auth: false,
      body: {
        'email': email,
        'username': username,
        'password': password,
        'acceptedPrivacyNotice': acceptedPrivacyNotice,
        'client': ApiConfig.clientType,
      },
    );
    return _saveSession(json as Map<String, dynamic>);
  }

  /// Revoca la sesión en el servidor (si se puede) y borra los tokens locales.
  Future<void> logout() async {
    final refreshToken = await _tokens.readRefreshToken();
    try {
      if (refreshToken != null) {
        await _api.post('/auth/logout', auth: false, body: {'refreshToken': refreshToken});
      }
    } finally {
      await _tokens.clear();
    }
  }

  Future<bool> hasStoredSession() async => await _tokens.readRefreshToken() != null;

  /// Valida la sesión guardada pidiendo la cuenta; el [ApiClient] renueva el
  /// access token si ya expiró.
  Future<Account> restoreSession() async {
    final json = await _api.get('/account');
    return Account.fromJson(json as Map<String, dynamic>);
  }

  Future<void> clearLocalSession() => _tokens.clear();

  Future<SessionPlayer> _saveSession(Map<String, dynamic> json) async {
    final tokens = TokenResponse.fromJson(json);
    await _tokens.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
    return tokens.player;
  }
}
