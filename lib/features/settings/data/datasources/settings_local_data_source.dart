// lib/features/settings/data/datasources/settings_local_data_source.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fuente de datos local para configuraciones
/// Maneja la persistencia usando SharedPreferences
abstract class SettingsLocalDataSource {
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode themeMode);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _themeModeKey = 'theme_mode';

  SettingsLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<ThemeMode> getThemeMode() async {
    final themeModeString = sharedPreferences.getString(_themeModeKey);

    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  @override
  Future<void> setThemeMode(ThemeMode themeMode) async {
    String themeModeString;

    switch (themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }

    await sharedPreferences.setString(_themeModeKey, themeModeString);
  }
}
