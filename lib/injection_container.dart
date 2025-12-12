// lib/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/database/database_helper.dart';

// Settings
import 'features/settings/data/datasources/settings_local_data_source.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/domain/usecases/get_theme_mode.dart';
import 'features/settings/domain/usecases/set_theme_mode.dart';
import 'features/settings/presentation/cubit/theme_cubit.dart';

// Events
import 'features/events/data/datasources/eventos_local_data_source.dart';
import 'features/events/data/repositories/eventos_repository_impl.dart';
import 'features/events/domain/repositories/eventos_repository.dart';
import 'features/events/domain/usecases/crear_evento.dart';
import 'features/events/domain/usecases/obtener_todos_los_eventos.dart';
import 'features/events/domain/usecases/actualizar_evento.dart';
import 'features/events/domain/usecases/eliminar_evento.dart';
import 'features/events/domain/usecases/obtener_evento_con_recordatorios.dart';
import 'features/events/presentation/cubit/eventos_cubit.dart';

// Notifications
import 'features/notifications/data/datasources/notificaciones_local_data_source.dart';
import 'features/notifications/data/repositories/notificaciones_repository_impl.dart';
import 'features/notifications/domain/repositories/notificaciones_repository.dart';
import 'features/notifications/domain/usecases/crear_notificacion_log.dart';
import 'features/notifications/domain/usecases/obtener_notificaciones_filtradas.dart';
import 'features/notifications/domain/usecases/marcar_notificacion.dart';
import 'features/notifications/domain/usecases/marcar_todas_como_leidas.dart';
import 'features/notifications/presentation/cubit/notificaciones_cubit.dart';

// Timeline
import 'features/timeline/presentation/cubit/timeline_cubit.dart';

final getIt = GetIt.instance;

/// Configuración completa de inyección de dependencias
Future<void> configureDependencies() async {
  // ============================================
  // CORE - Externos
  // ============================================

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Database Helper
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

  // ============================================
  // SETTINGS FEATURE
  // ============================================

  // Data Sources
  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetThemeMode(getIt()));
  getIt.registerLazySingleton(() => SetThemeMode(getIt()));

  // Cubits
  getIt.registerFactory(
    () => ThemeCubit(getThemeMode: getIt(), setThemeMode: getIt()),
  );

  // ============================================
  // EVENTS FEATURE
  // ============================================

  // Data Sources
  getIt.registerLazySingleton<EventosLocalDataSource>(
    () => EventosLocalDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<EventosRepository>(
    () => EventosRepositoryImpl(getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => CrearEvento(getIt()));
  getIt.registerLazySingleton(() => ObtenerTodosLosEventos(getIt()));
  getIt.registerLazySingleton(() => ActualizarEvento(getIt()));
  getIt.registerLazySingleton(() => EliminarEvento(getIt()));
  getIt.registerLazySingleton(() => ObtenerEventoConRecordatorios(getIt()));

  // Cubits
  getIt.registerFactory(
    () => EventosCubit(
      crearEvento: getIt(),
      obtenerTodosLosEventos: getIt(),
      actualizarEvento: getIt(),
      eliminarEvento: getIt(),
      obtenerEventoConRecordatorios: getIt(),
      crearNotificacionLog: getIt(), // Necesita el use case de notificaciones
    ),
  );

  // ============================================
  // NOTIFICATIONS FEATURE
  // ============================================

  // Data Sources
  getIt.registerLazySingleton<NotificacionesLocalDataSource>(
    () => NotificacionesLocalDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<NotificacionesRepository>(
    () => NotificacionesRepositoryImpl(getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => CrearNotificacionLog(getIt()));
  getIt.registerLazySingleton(() => ObtenerNotificacionesFiltradas(getIt()));
  getIt.registerLazySingleton(() => MarcarNotificacion(getIt()));
  getIt.registerLazySingleton(() => MarcarTodasComoLeidas(getIt()));

  // Cubits
  getIt.registerFactory(
    () => NotificacionesCubit(
      obtenerNotificacionesFiltradas: getIt(),
      marcarNotificacion: getIt(),
      marcarTodasComoLeidas: getIt(),
    ),
  );

  // ============================================
  // TIMELINE FEATURE
  // ============================================

  // Cubits
  getIt.registerFactory(
    () => TimelineCubit(
      obtenerTodosLosEventos: getIt(),
      crearNotificacionLog: getIt(),
    ),
  );
}
