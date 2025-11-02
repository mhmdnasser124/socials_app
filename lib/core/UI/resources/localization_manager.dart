import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:socials_app/main.dart';

abstract class LocalizationManager {
  static const String translationsPath = 'assets/translations';
  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];
  static const Locale fallbackLocale = Locale('en');

  static bool get isArabic =>
      (MyApp.appContext?.locale.languageCode ?? 'en') == 'ar';

  static bool get isEnglish =>
      (MyApp.appContext?.locale.languageCode ?? 'en') == 'en';

  static Future<void> changeLanguage(String language) async {
    final context = MyApp.appContext;
    if (context != null && supportedLocales.contains(Locale(language))) {
      await context.setLocale(Locale(language));
    }
  }

  static Future<void> toggleLanguage() async {
    final context = MyApp.appContext;
    if (context != null) {
      final currentLang = context.locale.languageCode;
      final newLocale = currentLang == 'en' ? 'ar' : 'en';
      await changeLanguage(newLocale);
    }
  }
}
