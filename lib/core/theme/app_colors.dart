import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42D4);

  // Secondary
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryLight = Color(0xFFFF9B9B);

  // Background
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F1F8);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color textHint = Color(0xFFA0A0B0);

  // Game elements
  static const Color xpGold = Color(0xFFFFD700);
  static const Color heartRed = Color(0xFFFF4757);
  static const Color diamondBlue = Color(0xFF00D4FF);
  static const Color streakOrange = Color(0xFFFF7F50);
  static const Color success = Color(0xFF2ED573);
  static const Color error = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFFA502);

  // Difficulty
  static const Color easy = Color(0xFF2ED573);
  static const Color medium = Color(0xFFFFA502);
  static const Color hard = Color(0xFFFF4757);

  // Dark mode variants
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkTextHint = Color(0xFF757575);

  // ---------------------------------------------------------------------------
  // Context-aware helpers — return the right color for current brightness.
  // ---------------------------------------------------------------------------
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color backgroundOf(BuildContext context) =>
      _isDark(context) ? darkBackground : background;

  static Color surfaceOf(BuildContext context) =>
      _isDark(context) ? darkSurface : surface;

  static Color surfaceVariantOf(BuildContext context) =>
      _isDark(context) ? darkSurfaceVariant : surfaceVariant;

  static Color textPrimaryOf(BuildContext context) =>
      _isDark(context) ? darkTextPrimary : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      _isDark(context) ? darkTextSecondary : textSecondary;

  static Color textHintOf(BuildContext context) =>
      _isDark(context) ? darkTextHint : textHint;

  /// Card-like surface color (replaces hardcoded `Colors.white`).
  static Color cardOf(BuildContext context) =>
      _isDark(context) ? darkSurface : Colors.white;
}
