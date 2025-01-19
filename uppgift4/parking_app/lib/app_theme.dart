import 'package:flutter/material.dart';

class AppTheme {
  // Define colors
  static const Color primaryColor = Colors.lightBlue;
  static const Color secondaryColor = Colors.green;
  static const Color textColor = Colors.white;
  static const Color lightBackgroundColor = Color(0xFFE9EDF0);
  static const Color darkBackgroundColor = Color(0xFF13212C);
  static const Color headingRowColor = Colors.lightBlue;
  static const Color errorColor = Colors.red;

  // Navigation bar colors
  static BottomNavigationBarThemeData get bottomNavBarThemeLight =>
      const BottomNavigationBarThemeData(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.lightBlue,
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      );

  static BottomNavigationBarThemeData get bottomNavBarThemeDark =>
      const BottomNavigationBarThemeData(
        selectedItemColor: Colors.amber,
        unselectedItemColor: Color.fromARGB(255, 245, 210, 210),
        backgroundColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      );

  // Define themes
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.lightBlue,
    scaffoldBackgroundColor: lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: textColor,
    ),
    bottomNavigationBarTheme: bottomNavBarThemeLight,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
      foregroundColor: textColor,
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackgroundColor,
      foregroundColor: textColor,
    ),
    bottomNavigationBarTheme: bottomNavBarThemeDark,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
      foregroundColor: textColor,
    ),
  );
}
