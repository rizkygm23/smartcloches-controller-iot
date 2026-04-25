import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color bgColor = Color(0xFF05070A);
  static const Color cardBg = Color(0xFF10141C);
  static const Color accentPrimary = Color(0xFF10B981);
  static const Color accentSecondary = Color(0xFF3B82F6);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color danger = Color(0xFFEF4444);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color cardBgTranslucent = Color(0xB310141C);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgColor,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: cardBg,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
