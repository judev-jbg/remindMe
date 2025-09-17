// lib/features/settings/domain/usecases/set_theme_mode.dart

import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

/// Caso de uso para guardar el modo de tema
class SetThemeMode {
  final SettingsRepository repository;

  SetThemeMode(this.repository);

  Future<Either<Failure, void>> call(ThemeMode themeMode) async {
    return await repository.setThemeMode(themeMode);
  }
}
