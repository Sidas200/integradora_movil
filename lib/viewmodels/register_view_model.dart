import '../data/repositories/auth_repository.dart';
import 'base_view_model.dart';
import 'session_view_model.dart';

class RegisterViewModel extends BaseViewModel {
  RegisterViewModel(this._auth, this._session);

  final AuthRepository _auth;
  final SessionViewModel _session;

  static final _usernamePattern = RegExp(r'^[A-Za-z0-9_]{3,20}$');

  bool _acceptedPrivacy = false;
  bool get acceptedPrivacy => _acceptedPrivacy;

  void setAcceptedPrivacy(bool value) {
    _acceptedPrivacy = value;
    notifyListeners();
  }

  // Mismas reglas que valida el backend.
  String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Escribe tu correo.';
    if (!v.contains('@') || v.length > 254) return 'Correo inválido.';
    return null;
  }

  String? validateUsername(String? value) {
    if (!_usernamePattern.hasMatch(value?.trim() ?? '')) {
      return 'De 3 a 20 letras, números o guion bajo.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final length = value?.length ?? 0;
    if (length < 8 || length > 72) return 'De 8 a 72 caracteres.';
    return null;
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    // El botón de registro se deshabilita mientras no se acepte el aviso.
    if (!_acceptedPrivacy) return;
    await runTask(() async {
      final player = await _auth.register(
        email: email.trim(),
        username: username.trim(),
        password: password,
        acceptedPrivacyNotice: true,
      );
      _session.signedIn(player.username);
    });
  }
}
