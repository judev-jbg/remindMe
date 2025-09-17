// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'features/settings/presentation/cubit/theme_cubit.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación de pantalla
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Configurar inyección de dependencias
  await configureDependencies();

  runApp(const RemindMeApp());
}

/// Aplicación principal con soporte para temas y navegación
class RemindMeApp extends StatelessWidget {
  const RemindMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ThemeCubit>()..loadTheme(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'RemindMe',
            debugShowCheckedModeBanner: false,

            // Configuración de temas
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,

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
