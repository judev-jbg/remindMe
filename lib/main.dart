// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'features/settings/presentation/cubit/theme_cubit.dart';
import 'features/events/presentation/cubit/eventos_cubit.dart';
import 'features/notifications/presentation/cubit/notificaciones_cubit.dart';
import 'features/timeline/presentation/cubit/timeline_cubit.dart';
import 'injection_container.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación de pantalla
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Inicializar formatos de fecha en español
  await initializeDateFormatting('es_ES', null);

  // Configurar inyección de dependencias
  await configureDependencies();

  // Inicializar servicio de notificaciones
  final notificationService = getIt<NotificationService>();
  await notificationService.initialize();
  await notificationService.requestPermissions();
  await notificationService.showImmediateNotification(
    id: 999,
    title: '🧪 Test de Notificación',
    body: 'Si ves esto, las notificaciones funcionan!',
  );

  runApp(const RemindMeApp());
}

/// Aplicación principal con soporte para temas y navegación
class RemindMeApp extends StatelessWidget {
  const RemindMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Theme Cubit
        BlocProvider(create: (context) => getIt<ThemeCubit>()..loadTheme()),

        // Events Cubit
        BlocProvider(
          create: (context) => getIt<EventosCubit>()..cargarEventos(),
        ),

        // Notifications Cubit
        BlocProvider(
          create: (context) =>
              getIt<NotificacionesCubit>()..cargarNotificaciones(),
        ),

        // Timeline Cubit
        BlocProvider(
          create: (context) => getIt<TimelineCubit>()..cargarTimeline(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'RemindMe',
            debugShowCheckedModeBanner: false,

            // Configuración de temas
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,

            // Localización en español
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('es', 'ES')],
            locale: const Locale('es', 'ES'),

            // Configuración de rutas
            routerConfig: AppRouter.router,

            // Configuraciones adicionales
            builder: (context, child) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness:
                      Theme.of(context).brightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light,
                  systemNavigationBarColor: Theme.of(
                    context,
                  ).colorScheme.surface,
                  systemNavigationBarIconBrightness:
                      Theme.of(context).brightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
