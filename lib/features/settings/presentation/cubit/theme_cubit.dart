// lib/features/settings/presentation/cubit/theme_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_theme_mode.dart';
import '../../domain/usecases/set_theme_mode.dart';

/// Cubit para manejar el estado del tema de la aplicación
/// Persiste la preferencia del usuario y maneja cambios de tema
class ThemeCubit extends Cubit<ThemeState> {
  final GetThemeMode _getThemeMode;
  final SetThemeMode _setThemeMode;

  ThemeCubit({
    required GetThemeMode getThemeMode,
    required SetThemeMode setThemeMode,
  }) : _getThemeMode = getThemeMode,
       _setThemeMode = setThemeMode,
       super(const ThemeState(ThemeMode.system));

  /// Carga el tema guardado en las preferencias
  Future<void> loadTheme() async {
    try {
      final result = await _getThemeMode();
      result.fold(
        (failure) {
          // En caso de error, mantener tema del sistema
          emit(const ThemeState(ThemeMode.system));
        },
        (themeMode) {
          emit(ThemeState(themeMode));
        },
      );
    } catch (e) {
      // Manejo de errores inesperados
      emit(const ThemeState(ThemeMode.system));
    }
  }

  /// Cambia el tema y lo persiste en las preferencias
  Future<void> changeTheme(ThemeMode themeMode) async {
    try {
      emit(ThemeState(themeMode));
      await _setThemeMode(themeMode);
    } catch (e) {
      // En caso de error, revertir el estado
      await loadTheme();
    }
  }
}

/// Estado del tema de la aplicación
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}
