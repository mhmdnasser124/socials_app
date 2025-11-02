import 'package:flutter/material.dart';

import '../../../main.dart';

abstract class AppSize {
  static double _screenWidth = 375;
  static double _screenHeight = 812;

  static double _scale(double value) {
    const double baseWidth = 375; // reference width (iPhone 12/13)
    return (value * (_screenWidth / baseWidth)).clamp(value * 0.75, value * 1.35);
  }

  static double _scaleHeight(double value) {
    const double baseHeight = 812;
    return (value * (_screenHeight / baseHeight)).clamp(value * 0.75, value * 1.35);
  }

  static double s(double value) => _scale(value);
  static double h(double value) => _scaleHeight(value);

  static double s1 = s(1);
  static double s2 = s(2);
  static double s1_5 = s(1.5);
  static double s4 = s(4);
  static double s6 = s(6);
  static double s8 = s(8);
  static double s10 = s(10);
  static double s12 = s(12);
  static double s14 = s(14);
  static double s16 = s(16);
  static double s18 = s(18);
  static double s20 = s(20);
  static double s22 = s(22);
  static double s24 = s(24);
  static double s26 = s(26);
  static double s28 = s(28);
  static double s30 = s(30);
  static double s32 = s(32);
  static double s34 = s(34);
  static double s36 = s(36);
  static double s40 = s(40);
  static double s50 = s(50);
  static double s55 = s(55);
  static double s60 = s(60);
  static double s80 = s(80);
  static double s120 = s(120);

  static double fullWidth = _screenWidth;
  static double fullHeight = _screenHeight;

  static void refresh(BuildContext context) {
    _screenWidth = MediaQuery.sizeOf(context).width;
    _screenHeight = MediaQuery.sizeOf(context).height;
    s1 = s(1);
    s2 = s(2);
    s1_5 = s(1.5);
    s4 = s(4);
    s6 = s(6);
    s8 = s(8);
    s10 = s(10);
    s12 = s(12);
    s14 = s(14);
    s16 = s(16);
    s18 = s(18);
    s20 = s(20);
    s22 = s(22);
    s24 = s(24);
    s26 = s(26);
    s28 = s(28);
    s30 = s(30);
    s32 = s(32);
    s34 = s(34);
    s36 = s(36);
    s40 = s(40);
    s50 = s(50);
    s55 = s(55);
    s60 = s(60);
    s80 = s(80);
    s120 = s(120);
    fullWidth = _screenWidth;
    fullHeight = _screenHeight;
  }
}
