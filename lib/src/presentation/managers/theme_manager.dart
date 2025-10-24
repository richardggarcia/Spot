import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages theme state and persistence across app sessions
/// Provides a centralized way to switch between light and dark themes
/// CORREGIDO: Mejorado para manejo robusto de cambios de tema
class ThemeManager extends ChangeNotifier {
  static const String _themePreferenceKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  bool get isLightMode => _themeMode == ThemeMode.light;

  /// Initialize theme from saved preferences
  Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey);

      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.dark,
        );
        notifyListeners();
      }
    } catch (e) {
      // Error loading theme preference handled silently
    }
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    await _saveThemePreference();
    // CORREGIDO: notifyListeners() ahora forzará rebuild de todos los widgets que escuchan
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _saveThemePreference();
    notifyListeners();
  }

  /// Save current theme preference to storage
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, _themeMode.toString());
    } catch (e) {
      // Error saving theme preference handled silently
    }
  }
}
