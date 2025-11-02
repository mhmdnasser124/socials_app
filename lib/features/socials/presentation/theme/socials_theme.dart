import 'package:flutter/material.dart';

class SocialsTheme {
  static const Color scaffoldBackground = Color(0xFFEAEAEA);
  static const Color cardBackground = Colors.white;
  static const Color accent = Color(0xFF006C5D);
  static const Color accentSecondary = Color(0xFFDF7939);
  static const Color accentMuted = Color(0xFFE0F2EF);
  static const Color textSecondary = Color(0xFF6E7682);
  static const Color tabIndicator = Color(0xFF006C5D);
  static const Color tabInactive = Color(0xFF9CA4AF);
  static const Color chipsBackground = Color(0xFFF1F3F6);

  static Color mutedWithOpacity(double value) => accentMuted.withOpacity(value);
  static Color accentWithOpacity(double value) => accent.withOpacity(value);
}
