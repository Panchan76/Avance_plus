<<<<<<< HEAD
import 'package:flutter/material.dart';

import 'package:avance_plus/features/auth/presentation/pages/candidate_signup_page.dart';
import 'package:avance_plus/features/auth/presentation/pages/company_signup_page.dart';

class AccountTypePage extends StatelessWidget {
  const AccountTypePage({super.key});

  void _openCandidateSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CandidateSignupPage(),
      ),
    );
  }

  void _openCompanySignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CompanySignupPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Avance+',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Crie sua conta',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Escolha como você deseja utilizar o Avance+.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 40),

                  _AccountTypeCard(
                    icon: Icons.person_outline,
                    title: 'Sou candidato',
                    description:
                        'Quero encontrar vagas, acompanhar empresas e receber ajuda da assistente.',
                    buttonText: 'Criar conta de candidato',
                    onPressed: () {
                      _openCandidateSignup(context);
                    },
                  ),

                  const SizedBox(height: 20),

                  _AccountTypeCard(
                    icon: Icons.business_outlined,
                    title: 'Sou uma empresa',
                    description:
                        'Quero divulgar oportunidades e encontrar candidatos.',
                    buttonText: 'Criar conta de empresa',
                    onPressed: () {
                      _openCompanySignup(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  const _AccountTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFE4E8EE),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                icon,
                size: 38,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 10),

            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
=======
import 'package:flutter/material.dart';

import 'package:avance_plus/features/auth/presentation/pages/candidate_signup_page.dart';
import 'package:avance_plus/features/auth/presentation/pages/company_signup_page.dart';

class AccountTypePage extends StatelessWidget {
  const AccountTypePage({super.key});

  void _openCandidateSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CandidateSignupPage(),
      ),
    );
  }

  void _openCompanySignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CompanySignupPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Avance+',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Crie sua conta',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Escolha como você deseja utilizar o Avance+.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 40),

                  _AccountTypeCard(
                    icon: Icons.person_outline,
                    title: 'Sou candidato',
                    description:
                        'Quero encontrar vagas, acompanhar empresas e receber ajuda da assistente.',
                    buttonText: 'Criar conta de candidato',
                    onPressed: () {
                      _openCandidateSignup(context);
                    },
                  ),

                  const SizedBox(height: 20),

                  _AccountTypeCard(
                    icon: Icons.business_outlined,
                    title: 'Sou uma empresa',
                    description:
                        'Quero divulgar oportunidades e encontrar candidatos.',
                    buttonText: 'Criar conta de empresa',
                    onPressed: () {
                      _openCompanySignup(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  const _AccountTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFE4E8EE),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                icon,
                size: 38,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 10),

            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
>>>>>>> 6975be9 ( segundo commit)
}