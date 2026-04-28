import 'package:flutter/material.dart';

class AppTheme {
  // ── Clean White Modern Palette ──
  static const Color bgColor = Color(0xFFF5F7FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBgTranslucent = Color(0xF2FFFFFF);

  // Accent
  static const Color accentPrimary = Color(0xFF2563EB);    // blue
  static const Color accentSecondary = Color(0xFF7C3AED);  // purple
  static const Color accentTeal = Color(0xFF0D9488);       // teal

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Borders & misc
  static const Color glassBorder = Color(0x14000000);
  static const Color divider = Color(0xFFE2E8F0);

  // Sensor-specific colors
  static const Color tempColor = Color(0xFFF97316);    // orange
  static const Color humColor = Color(0xFF06B6D4);     // cyan
  static const Color rainColor = Color(0xFF6366F1);    // indigo

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgColor,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: cardBg,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  // ── Shadows ──
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
