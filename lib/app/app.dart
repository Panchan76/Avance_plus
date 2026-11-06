import 'package:flutter/material.dart';

import 'package:avance_plus/core/theme/app_theme.dart';
import 'package:avance_plus/features/auth/presentation/pages/welcome_page.dart';

class AvanceApp extends StatelessWidget {
  const AvanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avance+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomePage(),
    );
  }
}