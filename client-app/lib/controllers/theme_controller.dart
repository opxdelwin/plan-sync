import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppThemeController extends GetxController {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      background: Color(0xffEAF9E9),
      onBackground: Color(0xff061906),
      primary: Color(0x668ADC89),
      onPrimary: Color(0xff061906),
      secondary: Color(0xff2FC02C),
      onSecondary: Color(0xffffffff),
      error: Color(0xF5FF0000),
      onError: Color(0xffFFFFFF),
      surface: Color(0xffDCDCDC),
      onSurface: Color(0xff000000),
      tertiary: Color(0xff4048FF),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      background: Color(0xff061906),
      onBackground: Color(0xffEAF9E9),
      primary: Color(0x4d8ADC89),
      onPrimary: Color(0xffD8E7D7),
      secondary: Color(0xcc2FC02C),
      onSecondary: Color(0xffEAF9E9),
      error: Color(0xF5FF0000),
      onError: Color(0xffFFFFFF),
      surface: Color(0xff9ABE99),
      onSurface: Color(0xff000000),
      tertiary: Color(0xffEAF9E9),
    ),
  );

  /// toggles theme
  static toggleTheme() {
    Get.changeTheme(Get.isDarkMode ? lightTheme : darkTheme);
  }
}
