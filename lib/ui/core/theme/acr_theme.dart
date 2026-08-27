import 'package:flutter/material.dart';

class AcrColors {
  static const Color background = Color(0xFF050508);
  static const Color surface = Color(0xFF080A12);
  static const Color card = Color(0xFF0D101D);
  static const Color cardBorder = Color(0x1FFFFFFF);
  static const Color cyan = Color(0xFF38BDF8);
  static const Color cyanGlow = Color(0x3338BDF8);
  static const Color indigo = Color(0xFF6366F1);
  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}

class AcrTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AcrColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AcrColors.cyan,
        secondary: AcrColors.indigo,
        surface: AcrColors.surface,
      ),
      cardTheme: CardThemeData(
        color: AcrColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AcrColors.cardBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AcrColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AcrColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
