import 'package:flutter/material.dart';

/// Provider for managing app theme (light/dark mode).
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  /// Gets the current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Whether dark mode is enabled
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Toggles between light and dark mode
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  /// Sets the theme mode directly
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  /// Sets dark mode on or off
  void setDarkMode(bool isDark) {
    setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
