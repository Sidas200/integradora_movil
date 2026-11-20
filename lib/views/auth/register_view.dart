import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/auth_repository.dart';
import '../../viewmodels/register_view_model.dart';
import '../../viewmodels/session_view_model.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'auth_shell.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => RegisterViewModel(
        ctx.read<AuthRepository>(),
        ctx.read<SessionViewModel>(),
      ),
      child: const _RegisterForm(),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit(RegisterViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    // Si sale bien, la sesión cambia y App cierra esta pantalla.
    await vm.register(
      email: _email.text,
      username: _username.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterViewModel>();
    final p = context.palette;
    return AuthShell(
      sprite: AppArt.hikari,
      showBack: true,
      artTitle: 'Empieza tu viaje',
      artText:
          'Crea tu cuenta y tus partidas se guardarán en la nube mientras juegas.',
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(title: 'Crear cuenta', eyebrow: 'Mi cuenta'),
              FieldLabel(
                'Correo',
                child: TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: vm.validateEmail,
                ),
              ),
              FieldLabel(
                'Nombre de jugador',
                hint:
                    'De 3 a 20 letras, números o guion bajo. Así te verán en el juego.',
                child: TextFormField(
                  controller: _username,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newUsername],
                  validator: vm.validateUsername,
                ),
              ),
              FieldLabel(
                'Contraseña',
                hint: 'Entre 8 y 72 caracteres.',
                child: TextFormField(
                  controller: _password,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: vm.validatePassword,
                ),
              ),
              FieldLabel(
                'Repite la contraseña',
                child: TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  validator: (v) => v != _password.text
                      ? 'Las contraseñas no coinciden.'
                      : null,
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.m),
                onTap: () => vm.setAcceptedPrivacy(!vm.acceptedPrivacy),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Checkbox(
                        value: vm.acceptedPrivacy,
                        onChanged: (v) => vm.setAcceptedPrivacy(v ?? false),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Acepto el aviso de privacidad',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (vm.errorMessage != null) AlertBox(vm.errorMessage!),
              AppButton(
                label: 'Crear mi cuenta',
                loadingLabel: 'Creando cuenta…',
                expand: true,
                height: 52,
                loading: vm.isLoading,
                onPressed: vm.acceptedPrivacy ? () => _submit(vm) : null,
              ),
              AuthSwitch(
                question: '¿Ya tienes cuenta?',
                action: 'Inicia sesión',
                onTap: vm.isLoading ? null : () => Navigator.of(context).maybePop(),
              ),
              if (!vm.acceptedPrivacy)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Acepta el aviso de privacidad para crear tu cuenta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: p.textMuted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
