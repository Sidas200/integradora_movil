import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/auth_repository.dart';
import '../../viewmodels/login_view_model.dart';
import '../../viewmodels/session_view_model.dart';
import '../widgets/app_widgets.dart';
import 'auth_shell.dart';
import 'register_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => LoginViewModel(
        ctx.read<AuthRepository>(),
        ctx.read<SessionViewModel>(),
      ),
      child: const _LoginForm(),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(LoginViewModel vm) {
    if (!_formKey.currentState!.validate()) return;
    vm.login(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    return AuthShell(
      sprite: AppArt.tsuki,
      artTitle: 'Tu promesa te espera',
      artText:
          'Entra para ver tus partidas, logros y noticias desde cualquier lugar.',
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(title: 'Iniciar sesión', eyebrow: 'Mi cuenta'),
              FieldLabel(
                'Correo',
                child: TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  maxLength: 254,
                  buildCounter: _noCounter,
                  validator: vm.validateEmail,
                ),
              ),
              FieldLabel(
                'Contraseña',
                child: TextFormField(
                  controller: _password,
                  obscureText: true,
                  maxLength: 72,
                  buildCounter: _noCounter,
                  autofillHints: const [AutofillHints.password],
                  validator: vm.validatePassword,
                  onFieldSubmitted: (_) => _submit(vm),
                ),
              ),
              if (vm.errorMessage != null) AlertBox(vm.errorMessage!),
              const SizedBox(height: 4),
              AppButton(
                label: 'Entrar',
                loadingLabel: 'Entrando…',
                expand: true,
                height: 52,
                loading: vm.isLoading,
                onPressed: () => _submit(vm),
              ),
              AuthSwitch(
                question: '¿No tienes cuenta?',
                action: 'Crea una aquí',
                onTap: vm.isLoading
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterView()),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget? _noCounter(
  BuildContext context, {
  required int currentLength,
  required bool isFocused,
  required int? maxLength,
}) => null;
