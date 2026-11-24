import 'package:flutter/material.dart';

/// Identidade visual Avance+: azul-marinho, azul e superfícies claras.
/// Os componentes do aplicativo herdam esta configuração automaticamente.
class AppPalette {
  AppPalette._();
  static const navy = Color(0xFF102B53);
  static const blue = Color(0xFF2864E8);
  static const sky = Color(0xFF60A5FA);
  static const background = Color(0xFFF6F8FC);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF172B46);
  static const muted = Color(0xFF52647B);
  static const outline = Color(0xFFE3EAF4);
  static const paleBlue = Color(0xFFEAF2FF);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppPalette.blue,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppPalette.blue,
      onPrimary: Colors.white,
      primaryContainer: AppPalette.paleBlue,
      onPrimaryContainer: AppPalette.navy,
      secondary: AppPalette.navy,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFDDEBFF),
      onSecondaryContainer: AppPalette.navy,
      surface: AppPalette.surface,
      onSurface: AppPalette.ink,
      outline: AppPalette.outline,
      outlineVariant: AppPalette.outline,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppPalette.background,
      surfaceContainer: const Color(0xFFF1F5FB),
      surfaceContainerHigh: const Color(0xFFEAF1FA),
    );
    final radius = BorderRadius.circular(22);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppPalette.background,
      canvasColor: AppPalette.background,
      splashColor: AppPalette.sky.withValues(alpha: 0.12),
      dividerColor: AppPalette.outline,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppPalette.navy, letterSpacing: -0.8),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppPalette.navy, letterSpacing: -0.6),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppPalette.navy),
        titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppPalette.ink),
        titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppPalette.ink),
        bodyLarge: TextStyle(fontSize: 18, height: 1.5, color: AppPalette.ink),
        bodyMedium: TextStyle(fontSize: 16, height: 1.5, color: AppPalette.ink),
        bodySmall: TextStyle(fontSize: 14, height: 1.4, color: AppPalette.muted),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppPalette.navy, letterSpacing: -0.5),
        iconTheme: IconThemeData(color: AppPalette.navy),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: radius, side: const BorderSide(color: AppPalette.outline)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppPalette.outline,
          minimumSize: const Size(double.infinity, 58),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          elevation: 2,
          shadowColor: AppPalette.blue.withValues(alpha: 0.20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: AppPalette.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: AppPalette.navy,
        minimumSize: const Size(0, 54),
        side: const BorderSide(color: AppPalette.outline, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      )),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppPalette.blue)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        prefixIconColor: AppPalette.muted,
        hintStyle: const TextStyle(color: AppPalette.muted),
        labelStyle: const TextStyle(color: AppPalette.muted),
        border: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: AppPalette.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: AppPalette.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: AppPalette.blue, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: scheme.error)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: AppPalette.navy.withValues(alpha: 0.08),
        indicatorColor: AppPalette.paleBlue,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppPalette.blue : AppPalette.muted,
          size: 24,
        )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
          color: states.contains(WidgetState.selected) ? AppPalette.navy : AppPalette.muted,
        )),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppPalette.blue,
        unselectedItemColor: AppPalette.muted,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppPalette.blue,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppPalette.paleBlue,
        selectedColor: const Color(0xFFD8E9FF),
        side: const BorderSide(color: AppPalette.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(color: AppPalette.navy, fontWeight: FontWeight.w600),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppPalette.navy,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppPalette.blue),
      dividerTheme: const DividerThemeData(color: AppPalette.outline, thickness: 1),
    );
  }
}
