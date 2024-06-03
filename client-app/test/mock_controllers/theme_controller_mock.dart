import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:plan_sync/controllers/theme_controller.dart';

class MockAppThemeController extends GetxController
    with Mock
    implements AppThemeController {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0x668ADC89),
      onPrimary: Color(0xff061906),
      secondary: Color(0xff2FC02C),
      onSecondary: Color(0xffffffff),
      error: Color(0xF5FF0000),
      onError: Color(0xffFFFFFF),
      surface: Color(0xffEAF9E9),
      onSurface: Color(0xff061906),
      tertiary: Color(0xff4048FF),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0x4d8ADC89),
      onPrimary: Color(0xffD8E7D7),
      secondary: Color(0xcc2FC02C),
      onSecondary: Color(0xffEAF9E9),
      error: Color(0xF5FF0000),
      onError: Color(0xffFFFFFF),
      surface: Color(0xff061906),
      onSurface: Color(0xffEAF9E9),
      tertiary: Color(0xffEAF9E9),
    ),
  );

  /// toggles theme
  static toggleTheme() {
    Get.changeTheme(Get.isDarkMode ? lightTheme : darkTheme);
  }
}
