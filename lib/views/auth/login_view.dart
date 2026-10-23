import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/auth_repository.dart';
import '../../viewmodels/login_view_model.dart';
import '../../viewmodels/session_view_model.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: vm.validateEmail,
                ),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  validator: vm.validatePassword,
                  onFieldSubmitted: (_) => _submit(vm),
                ),
                const SizedBox(height: 16),
                if (vm.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      vm.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ElevatedButton(
                  onPressed: vm.isLoading ? null : () => _submit(vm),
                  child: vm.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Entrar'),
                ),
                TextButton(
                  onPressed: vm.isLoading
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterView()),
                          ),
                  child: const Text('Crear cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
