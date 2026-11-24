import 'package:avance_plus/core/theme/avance_widgets.dart';
import '../widgets/google_sign_in_button.dart';
import '../../data/auth_service.dart';
import 'auth_gate.dart';
import 'package:flutter/material.dart';

import 'package:avance_plus/features/auth/presentation/pages/account_type_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _hidePassword = true;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _message(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _login() async {
    if (_busy) return;
    if (!_emailController.text.trim().contains('@') || _passwordController.text.isEmpty) {
      _message('Informe seu e-mail e sua senha.');
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthService.instance.signIn(_emailController.text, _passwordController.text);
      if (mounted) openAuthenticatedRoot(context);
    } catch (error) {
      if (mounted) _message(authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_busy) return;
    if (!_emailController.text.trim().contains('@')) {
      _message('Preencha o campo e-mail para recuperar a senha.');
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthService.instance.resetPassword(_emailController.text);
      if (mounted) _message('Se houver uma conta com este e-mail, você receberá as instruções para redefinir a senha.');
    } catch (error) {
      if (mounted) _message(authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AccountTypePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Entrar',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const AvanceHero(
                icon: Icons.lock_open_rounded,
                title: 'Bem-vindo de volta!',
                subtitle: 'Entre na sua conta e continue construindo seu futuro profissional.',
              ),
              const SizedBox(height: 30),
              const SizedBox(height: 36),

              TextFormField(
                enabled: !_busy,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'Digite seu e-mail',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                enabled: !_busy,
                controller: _passwordController,
                obscureText: _hidePassword,
                textInputAction: TextInputAction.done,
                style: const TextStyle(
                  fontSize: 18,
                ),
                onFieldSubmitted: (_) {
                  _login();
                },
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Digite sua senha',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon: IconButton(
                    tooltip: _hidePassword
                        ? 'Mostrar senha'
                        : 'Ocultar senha',
                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
                    },
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _busy ? null : _resetPassword,
                  child: const Text(
                    'Esqueci minha senha',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _login,
                  icon: const Icon(
                    Icons.login,
                  ),
                  label: Text(_busy ? 'Entrando...' : 'Entrar'),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  const Expanded(
                    child: Divider(),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Text(
                      'ou',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),

                  const Expanded(
                    child: Divider(),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              GoogleSignInButton(enabled: !_busy,
                onBusyChanged: (busy) { if (mounted) setState(() => _busy = busy); }),

              const SizedBox(height: 28),

              Center(
                child: Text(
                  'Ainda não possui uma conta?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _openSignup,
                  icon: const Icon(
                    Icons.person_add_outlined,
                  ),
                  label: const Text(
                    'Criar conta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}