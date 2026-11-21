import '../data/repositories/auth_repository.dart';
import 'base_view_model.dart';
import 'session_view_model.dart';

class LoginViewModel extends BaseViewModel {
  LoginViewModel(this._auth, this._session);

  final AuthRepository _auth;
  final SessionViewModel _session;

  String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Escribe tu correo.';
    if (!v.contains('@')) return 'Correo inválido.';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Escribe tu contraseña.';
    return null;
  }

  Future<void> login(String email, String password) async {
    await runTask(() async {
      final player = await _auth.login(email: email.trim(), password: password);
      _session.signedIn(player.username);
    });
  }
}
