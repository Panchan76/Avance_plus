import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meu perfil',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 32),

            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(
                  Icons.person,
                  size: 70,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                'Usuário Avance+',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 32),

            const _ProfileOption(
              icon: Icons.person_outline,
              title: 'Dados pessoais',
            ),

            const _ProfileOption(
              icon: Icons.description_outlined,
              title: 'Currículo',
            ),

            const _ProfileOption(
              icon: Icons.favorite_border,
              title: 'Vagas salvas',
            ),

            const _ProfileOption(
              icon: Icons.settings_outlined,
              title: 'Configurações',
            ),

            const _ProfileOption(
              icon: Icons.help_outline,
              title: 'Ajuda',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileOption({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        minTileHeight: 68,
        leading: Icon(
          icon,
          size: 30,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          size: 30,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: Color(0xFFE4E8EE),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}