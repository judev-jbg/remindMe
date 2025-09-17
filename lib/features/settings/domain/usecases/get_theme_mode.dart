// lib/features/settings/domain/usecases/get_theme_mode.dart

import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

/// Caso de uso para obtener el modo de tema guardado
class GetThemeMode {
  final SettingsRepository repository;

  GetThemeMode(this.repository);

  Future<Either<Failure, ThemeMode>> call() async {
    return await repository.getThemeMode();
  }
}
