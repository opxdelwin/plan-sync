import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppThemeController extends GetxController {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF34A853), // Vibrant green
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF34A853),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color.fromARGB(255, 60, 122, 222), // Complementary blue
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFEA4335),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFE8E8E8), // Slightly darker surface
      onSurface: Color(0xFF202124),
      tertiary: Color(0xFFFFA000), // Accent yellow
      background: Color(0xFFE8F5E9), // Soft, light green background
      onBackground: Color(0xFF202124),
    ),
    scaffoldBackgroundColor:
        const Color(0xFFE8F5E9), // Soft, light green background
    appBarTheme: const AppBarTheme(
      color: Color(0xFF34A853),
      foregroundColor: Color(0xFFFFFFFF),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: Color(0xFF202124)),
      bodyMedium: TextStyle(color: Color(0xFF5F6368)),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF34A853),
      textTheme: ButtonTextTheme.primary,
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF34A853),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF8ADC89), // Light green from the calendar
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8ADC89),
      onPrimary: Color(0xFF121212),
      secondary: Color.fromARGB(255, 21, 80, 174), // A slightly darker green
      onSecondary: Color(0xFFE0E0E0),
      error: Color(0xFFFF5252),
      onError: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      onSurface: Color.fromARGB(255, 240, 240, 240),
      background: Color(0xFF121212), // Smooth, comfortable black
      onBackground: Color.fromARGB(255, 240, 240, 240),
      tertiary: Color.fromARGB(255, 234, 195, 0), // Light blue for accents
    ),
    scaffoldBackgroundColor:
        const Color(0xFF121212), // Smooth, comfortable black
    appBarTheme: const AppBarTheme(
      color: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFFE0E0E0),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: Color(0xFFE0E0E0)),
      bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF8ADC89),
      textTheme: ButtonTextTheme.primary,
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF8ADC89),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFF8ADC89),
      unselectedItemColor: Color(0xFFBDBDBD),
    ),
  );

  /// toggles theme
  static toggleTheme() {
    Get.changeTheme(Get.isDarkMode ? lightTheme : darkTheme);
  }
}
