import 'package:flutter/material.dart';
import '../../data/auth_service.dart';

class SignOutButton extends StatefulWidget {
  const SignOutButton({super.key});
  @override
  State<SignOutButton> createState() => _SignOutButtonState();
}
class _SignOutButtonState extends State<SignOutButton> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    icon: const Icon(Icons.logout),
    label: Text(_busy ? 'Saindo...' : 'Sair da conta'),
    onPressed: _busy ? null : () async {
      setState(() => _busy = true);
      try {
        await AuthService.instance.signOut();
        if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(error))));
        }
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    },
  );
}
