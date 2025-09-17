// lib/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/settings/data/datasources/settings_local_data_source.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/domain/usecases/get_theme_mode.dart';
import 'features/settings/domain/usecases/set_theme_mode.dart';
import 'features/settings/presentation/cubit/theme_cubit.dart';

final getIt = GetIt.instance;

/// Configuración de inyección de dependencias
@InjectableInit()
Future<void> configureDependencies() async {
  // Registrar SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Settings
  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton(() => GetThemeMode(getIt()));
  getIt.registerLazySingleton(() => SetThemeMode(getIt()));

  getIt.registerFactory(
    () => ThemeCubit(getThemeMode: getIt(), setThemeMode: getIt()),
  );
}
