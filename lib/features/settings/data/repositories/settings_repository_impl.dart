// lib/features/settings/data/repositories/settings_repository_impl.dart

import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

/// Implementación del repositorio de configuraciones
/// Maneja errores y convierte excepciones en objetos Failure
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, ThemeMode>> getThemeMode() async {
    try {
      final themeMode = await localDataSource.getThemeMode();
      return Right(themeMode);
    } catch (e) {
      return Left(CacheFailure('Error al obtener el tema: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> setThemeMode(ThemeMode themeMode) async {
    try {
      await localDataSource.setThemeMode(themeMode);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error al guardar el tema: ${e.toString()}'));
    }
  }
}
