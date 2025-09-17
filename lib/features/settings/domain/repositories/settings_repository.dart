// lib/features/settings/domain/repositories/settings_repository.dart

import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

/// Contrato del repositorio de configuraciones
/// Define las operaciones disponibles para la persistencia de configuraciones
abstract class SettingsRepository {
  /// Obtiene el modo de tema guardado
  Future<Either<Failure, ThemeMode>> getThemeMode();

  /// Guarda el modo de tema
  Future<Either<Failure, void>> setThemeMode(ThemeMode themeMode);
}
