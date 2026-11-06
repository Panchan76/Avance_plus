import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import '../pages/auth_gate.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key, this.enabled = true, required this.onBusyChanged});
  final bool enabled;
  final ValueChanged<bool> onBusyChanged;
  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}
class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _busy = false;
  Future<void> _continue() async {
    if (_busy || !widget.enabled) return;
    setState(() => _busy = true);
    widget.onBusyChanged(true);
    try {
      final signedIn = await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      if (signedIn) {
        openAuthenticatedRoot(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Entrada com Google cancelada. Você pode tentar novamente.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        widget.onBusyChanged(false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    if (!AuthService.supportsGoogleSignIn) return const SizedBox.shrink();
    return SizedBox(width: double.infinity,
      child: OutlinedButton(
        onPressed: !widget.enabled || _busy ? null : _continue,
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56)),
        child: Text(_busy ? 'Conectando ao Google...' : 'Continuar com Google'),
      ),
    );
  }
}
