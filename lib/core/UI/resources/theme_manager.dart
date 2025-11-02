import 'package:flutter/material.dart';

import 'color_manager.dart';

abstract class MainThemeApp {
  late ThemeData themeData;
}

class LightModeTheme implements MainThemeApp {
  @override
  ThemeData themeData = _buildTheme();
}

ThemeData _buildTheme() {
  final ColorScheme scheme = ColorScheme(
    brightness: Brightness.light,
    primary: ColorManager.colorPrimary,
    onPrimary: ColorManager.colorWhite,
    secondary: ColorManager.colorSecondary,
    onSecondary: ColorManager.colorWhite,
    background: ColorManager.colorBackground,
    onBackground: ColorManager.colorFontPrimary,
    surface: ColorManager.colorCard,
    onSurface: ColorManager.colorFontPrimary,
    error: ColorManager.colorError,
    onError: ColorManager.colorWhite,
    tertiary: ColorManager.colorTertiary,
    onTertiary: ColorManager.colorWhite,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.background,
    splashColor: ColorManager.colorSplash,
    dividerColor: Colors.transparent,
    textTheme: ThemeData(brightness: Brightness.light)
        .textTheme
        .apply(bodyColor: ColorManager.colorFontPrimary, displayColor: ColorManager.colorFontPrimary),
  );

  return base.copyWith(
    cardColor: scheme.surface,
    iconTheme: IconThemeData(color: scheme.primary),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.background,
      foregroundColor: scheme.onBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: scheme.primary),
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onBackground,
      ),
    ),
    cardTheme: CardTheme(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surface,
      surfaceTintColor: scheme.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(color: ColorManager.colorDivider, thickness: 1),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 6,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: scheme.surface,
      elevation: 4,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.onSurface.withOpacity(0.5),
      showUnselectedLabels: true,
      selectedIconTheme: IconThemeData(size: 26, color: scheme.primary),
      unselectedIconTheme: IconThemeData(size: 24, color: scheme.onSurface.withOpacity(0.5)),
      selectedLabelStyle: base.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: scheme.primary),
      unselectedLabelStyle: base.textTheme.labelSmall?.copyWith(color: scheme.onSurface.withOpacity(0.5)),
    ),
    dialogTheme: DialogTheme(backgroundColor: scheme.surface, surfaceTintColor: Colors.transparent),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: scheme.surface,
      headerBackgroundColor: scheme.primary,
      headerForegroundColor: scheme.onPrimary,
      dayStyle: base.textTheme.bodyMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
      weekdayStyle: base.textTheme.labelMedium?.copyWith(color: scheme.secondary, fontWeight: FontWeight.w700),
      yearStyle: base.textTheme.bodyMedium,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: scheme.surface,
      hourMinuteColor: scheme.primary.withOpacity(0.08),
      dayPeriodColor: scheme.primary.withOpacity(0.12),
      dialHandColor: scheme.primary,
      dialBackgroundColor: scheme.primary.withOpacity(0.08),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: scheme.primary),
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: scheme.onSurface.withOpacity(0.6)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorManager.colorTextFieldFill,
      hintStyle: base.textTheme.bodyMedium?.copyWith(color: ColorManager.colorGrey3),
      errorStyle: base.textTheme.bodySmall?.copyWith(color: ColorManager.colorError, fontWeight: FontWeight.w600),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: ColorManager.colorTextFieldEnabledBorder),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: ColorManager.colorTextFieldEnabledBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: ColorManager.colorTextFieldFocusedBorder, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: ColorManager.colorTextFieldErrorBorder),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: ColorManager.colorTextFieldErrorBorder, width: 1.2),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        padding: WidgetStatePropertyAll(const EdgeInsets.symmetric(vertical: 12, horizontal: 8)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
      textStyle: base.textTheme.bodyMedium,
    ),
  );
}
