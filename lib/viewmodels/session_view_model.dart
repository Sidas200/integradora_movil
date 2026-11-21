import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../data/repositories/auth_repository.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

/// Estado global de la sesión. Decide si se muestra el login o la app.
class SessionViewModel extends ChangeNotifier {
  SessionViewModel(this._auth);

  final AuthRepository _auth;

  SessionStatus _status = SessionStatus.unknown;
  String? _username;

  SessionStatus get status => _status;
  String? get username => _username;

  /// Al abrir la app revisa si hay una sesión guardada que siga siendo válida.
  Future<void> restore() async {
    if (!await _auth.hasStoredSession()) {
      _set(SessionStatus.unauthenticated);
      return;
    }
    try {
      final account = await _auth.restoreSession();
      _username = account.username;
      _set(SessionStatus.authenticated);
    } on ApiException catch (e) {
      if (e.isUnauthenticated) await _auth.clearLocalSession();
      _set(SessionStatus.unauthenticated);
    }
  }

  void signedIn(String username) {
    _username = username;
    _set(SessionStatus.authenticated);
  }

  Future<void> logout() async {
    try {
      await _auth.logout();
    } catch (_) {
      // Aunque falle la red, los tokens locales ya se borraron.
    }
    _username = null;
    _set(SessionStatus.unauthenticated);
  }

  /// Lo llama el ApiClient cuando el refresh token ya no es válido.
  Future<void> expired() async {
    if (_status != SessionStatus.authenticated) return;
    await _auth.clearLocalSession();
    _username = null;
    _set(SessionStatus.unauthenticated);
  }

  void _set(SessionStatus status) {
    _status = status;
    notifyListeners();
  }
}
