import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Identidade visual reutilizável, sem alterar as regras de negócio.
class AvanceHero extends StatelessWidget {
  const AvanceHero({super.key, required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [AppPalette.navy, AppPalette.blue, Color(0xFF548FF6)],
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [BoxShadow(color: AppPalette.blue.withValues(alpha: 0.20), blurRadius: 25, offset: const Offset(0, 12))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.17), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: Colors.white, size: 32)),
      const SizedBox(height: 20),
      Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
      const SizedBox(height: 8),
      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.90))),
    ]),
  );
}
