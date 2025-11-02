import 'package:flutter/material.dart';
import 'package:socials_app/main.dart';

abstract class FontManager {
  static const String _arabicFontFamily = '';
  static const String _englishFontFamily = 'Poppins';

  static String getFontFamily(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return _arabicFontFamily;
      case 'en':
      default:
        return _englishFontFamily;
    }
  }

  static TextDirection getTextDirection(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return TextDirection.rtl;
      case 'en':
      default:
        return TextDirection.ltr;
    }
  }
}

abstract class FontSize {
  static double get s9 => _AdaptiveFontSize.getFontSize(9);
  static double get s10 => _AdaptiveFontSize.getFontSize(10);
  static double get s10_5 => _AdaptiveFontSize.getFontSize(10.5);
  static double get s11 => _AdaptiveFontSize.getFontSize(11);
  static double get s12 => _AdaptiveFontSize.getFontSize(12);
  static double get s13 => _AdaptiveFontSize.getFontSize(13);
  static double get s14 => _AdaptiveFontSize.getFontSize(14);
  static double get s15 => _AdaptiveFontSize.getFontSize(15);
  static double get s16 => _AdaptiveFontSize.getFontSize(16);
  static double get s17 => _AdaptiveFontSize.getFontSize(17);
  static double get s18 => _AdaptiveFontSize.getFontSize(18);
  static double get s19 => _AdaptiveFontSize.getFontSize(19);
  static double get s20 => _AdaptiveFontSize.getFontSize(20);
  static double get s22 => _AdaptiveFontSize.getFontSize(22);
  static double get s24 => _AdaptiveFontSize.getFontSize(24);
  static double get s28 => _AdaptiveFontSize.getFontSize(28);
  static double get s30 => _AdaptiveFontSize.getFontSize(30);
  static double get s36 => _AdaptiveFontSize.getFontSize(36);
  static double get s50 => _AdaptiveFontSize.getFontSize(50);
}

class _AdaptiveFontSize {
  static double getFontSize(double baseFontSize) {
    if (MyApp.appContext == null) return baseFontSize;
    double screenWidth = MediaQuery.sizeOf(MyApp.appContext!).width;
    const double baseScreenWidth = 375.0; // Standard screen width
    double scaleFactor = screenWidth / baseScreenWidth;
    return baseFontSize * scaleFactor;
  }
}