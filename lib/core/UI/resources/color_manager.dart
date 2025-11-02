import 'package:flutter/material.dart';

abstract class ColorManager {
  // Brand palette
  static const Color colorPrimary = Color(0xFF006C5D);
  static const Color colorSecondary = Color(0xFFDF7939);
  static const Color colorTertiary = Color(0xFF03BEA4);

  // Surfaces
  static const Color colorBackground = Color(0xFFF5F7FA);
  static const Color colorCard = Color(0xFFFFFFFF);
  static const Color colorSurfaceMuted = Color(0xFFE9EDF2);

  // Typography
  static const Color colorFontPrimary = Color(0xFF111827);
  static const Color colorFontSecondary = Color(0xFF6B7280);

  // States
  static const Color colorSuccess = Color(0xFF34C759);
  static const Color colorError = Color(0xFFD22F27);
  static const Color colorWarning = Color(0xFFFFC107);

  // Greys
  static const Color colorGrey = Color(0xFF6B7280);
  static const Color colorGrey1 = Color(0xFFF1F3F5);
  static const Color colorGrey2 = Color(0xFFE0E6ED);
  static const Color colorGrey3 = Color(0xFFA6B0BD);
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color colorBlack = Color(0xFF0C0C0C);

  // Accents
  static const Color colorToast = Color(0xFFFFFFFF);
  static const Color colorSplash = Color(0x1A006C5D);

  // Input/Text field
  static const Color colorTextFieldFill = Color(0xFFF8FAFC);
  static Color colorTextFieldFillError = const Color(0xFFD22F27).withOpacity(0.08);
  static Color colorTextFieldEnabledBorder = colorPrimary.withOpacity(0.18);
  static Color colorTextFieldFocusedBorder = colorPrimary.withOpacity(0.42);
  static Color colorTextFieldErrorBorder = const Color(0xFFD22F27);
  static Color colorPlaceHolder = colorPrimary.withOpacity(0.32);

  // Misc
  static Color colorDivider = colorPrimary.withOpacity(0.08);
  static const Color colorSpin = Color(0xFFFFFFFF);
  static const Color colorBlue = Color(0xFF007AFF);

  static Color shimmerBaseColor = Colors.grey.shade300;
  static Color shimmerHighlightColor = Colors.grey.shade100;
}
