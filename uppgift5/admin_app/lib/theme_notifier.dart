import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;


  void toggleTheme() {
  _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  debugPrint("🎨 Theme changed to: $_themeMode");
  notifyListeners();
}

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

