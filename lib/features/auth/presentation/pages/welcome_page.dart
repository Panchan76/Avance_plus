import 'package:avance_plus/core/theme/avance_widgets.dart';
import '../widgets/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:avance_plus/core/theme/app_theme.dart';

import 'package:avance_plus/features/auth/presentation/pages/account_type_page.dart';
import 'package:avance_plus/features/auth/presentation/pages/login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}
class _WelcomePageState extends State<WelcomePage> {
  bool _busy = false;

  void _openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  void _openSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AccountTypePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: !_busy, child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 28),
              const AvanceHero(
                icon: Icons.auto_awesome_rounded,
                title: 'Avance+',
                subtitle: 'Seu próximo passo começa aqui. Encontre oportunidades, organize entrevistas e conte com uma assistente na sua jornada.',
              ),
              const SizedBox(height: 30),
              Text('Oportunidades para todos', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text('Uma experiência simples, acolhedora e feita para você avançar.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : () {
                    _openLogin(context);
                  },
                  icon: const Icon(
                    Icons.login,
                  ),
                  label: const Text(
                    'Entrar',
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () {
                    _openSignup(context);
                  },
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

              const SizedBox(height: 20),
              GoogleSignInButton(enabled: !_busy,
                onBusyChanged: (busy) { if (mounted) setState(() => _busy = busy); }),

              const SizedBox(height: 24),

              Text(
                'Oportunidades, conexões e apoio em um só lugar.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}