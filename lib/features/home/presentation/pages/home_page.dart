import 'package:flutter/material.dart';
import '../../../catalog/resume_page.dart';

/// Página inicial original do Avance+, com apresentação visual renovada.
/// Não altera o catálogo, a seleção de cargos ou a candidatura.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onViewJobs});
  final VoidCallback onViewJobs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
            children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF102B53), Color(0xFF2864E8)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFF2864E8).withValues(alpha: .18),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  )],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), borderRadius: BorderRadius.circular(30)),
                      child: const Text('BEM-VINDO AO AVANCE+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1)),
                    ),
                    const SizedBox(height: 20),
                    const Text('Sua experiência\ntem valor.', style: TextStyle(color: Colors.white, fontSize: 34, height: 1.12, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    Text('Encontre novas oportunidades e mostre às empresas tudo o que você sabe fazer.', style: TextStyle(color: Colors.white.withValues(alpha: .91), fontSize: 16, height: 1.5)),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: onViewJobs,
                      style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF173B78), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                      icon: const Icon(Icons.work_outline_rounded),
                      label: const Text('Conhecer os cargos'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text('Por onde começar?', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Tudo o que você precisa, em poucos passos.', style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
              const SizedBox(height: 18),
              _ActionTile(
                icon: Icons.badge_outlined,
                title: 'Explore os cargos',
                subtitle: 'Escolha as áreas em que deseja trabalhar.',
                onTap: onViewJobs,
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.description_outlined,
                title: 'Meu currículo',
                subtitle: 'Apresente suas experiências e habilidades.',
                onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ResumePage())),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(18)),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_user_outlined, color: Color(0xFF2864E8)),
                    SizedBox(width: 12),
                    Expanded(child: Text('Você controla a visibilidade do seu currículo. Essa opção pode ser alterada em Meu currículo.', style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF173B78)))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE0E8F5)), borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFF2864E8), size: 27)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(color: Color(0xFF52647B), fontSize: 14, height: 1.35)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF2864E8)),
        ]),
      ),
    ),
  );
}
