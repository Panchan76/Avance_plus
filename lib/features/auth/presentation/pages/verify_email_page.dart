import 'package:avance_plus/core/theme/avance_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/auth_service.dart';

/// Bloqueia a navegação de contas com senha até a confirmação do endereço.
class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, required this.user, required this.onVerified});
  final User user;
  final VoidCallback onVerified;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _busy = false;
  DateTime? _lastSent;
  String? _message;

  Future<void> _checkVerification() async {
    if (_busy) return;
    setState(() { _busy = true; _message = null; });
    try {
      await widget.user.reload();
      final current = FirebaseAuth.instance.currentUser;
      if (!mounted) return;
      if (current != null && current.uid == widget.user.uid && current.emailVerified) {
        await current.getIdToken(true);
        if (mounted) widget.onVerified();
      } else {
        setState(() => _message = 'O e-mail ainda não foi confirmado. Abra o link recebido e tente novamente.');
      }
    } catch (error) {
      if (mounted) setState(() => _message = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_busy) return;
    final now = DateTime.now();
    if (_lastSent != null && now.difference(_lastSent!) < const Duration(seconds: 60)) {
      setState(() => _message = 'Aguarde 1 minuto antes de solicitar outro e-mail.');
      return;
    }
    setState(() { _busy = true; _message = null; });
    try {
      await widget.user.reload();
      final current = FirebaseAuth.instance.currentUser;
      if (current == null || current.uid != widget.user.uid) return;
      if (current.emailVerified) {
        await current.getIdToken(true);
        if (mounted) widget.onVerified();
        return;
      }
      await current.sendEmailVerification();
      if (mounted) setState(() {
        _lastSent = DateTime.now();
        _message = 'Enviamos um novo link. Confira também a pasta de spam.';
      });
    } catch (error) {
      if (mounted) setState(() => _message = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar e-mail')),
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const AvanceHero(icon: Icons.mark_email_unread_rounded, title: 'Verifique seu e-mail', subtitle: 'Só falta confirmar seu endereço para começar a usar o Avance+.'),
            const SizedBox(height: 12),
            const Text('Para proteger sua conta no Avance+, confirme seu endereço de e-mail antes de continuar.', textAlign: TextAlign.center),
            const SizedBox(height: 10),
            SelectableText(widget.user.email ?? '', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            const Text('Seu cadastro só será ativado após confirmar o e-mail. Se você não tem acesso a esse endereço, escolha Sair / usar outra conta e cadastre um e-mail seu.', textAlign: TextAlign.center),
            const SizedBox(height: 10),
            const Text('Enviamos um link após o cadastro. Confira sua caixa de entrada e a pasta de spam.', textAlign: TextAlign.center),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(_message!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.primary)),
            ],
            const SizedBox(height: 24),
            if (_busy) const CircularProgressIndicator(),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: _busy ? null : _checkVerification,
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Já confirmei meu e-mail'),
            )),
            const SizedBox(height: 10),
            TextButton.icon(onPressed: _busy ? null : _resend,
              icon: const Icon(Icons.forward_to_inbox_outlined),
              label: const Text('Reenviar e-mail de confirmação')),
            const SizedBox(height: 8),
            TextButton(onPressed: _busy ? null : () async {
              try { await AuthService.instance.signOut(); }
              catch (error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authErrorMessage(error)))); }
            }, child: const Text('Sair / usar outra conta')),
          ]),
        ),
      ))),
    );
  }
}
