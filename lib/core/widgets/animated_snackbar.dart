// lib/core/widgets/animated_snackbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Snackbar personalizado con animaciones suaves y diseño moderno
/// Soporta diferentes tipos de mensajes con iconos y colores apropiados
class AnimatedSnackbar {
  static const Duration _defaultDuration = Duration(seconds: 3);

  /// Muestra un snackbar de éxito
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = _defaultDuration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _show(
      context: context,
      message: message,
      type: _SnackbarType.success,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Muestra un snackbar de error
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = _defaultDuration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _show(
      context: context,
      message: message,
      type: _SnackbarType.error,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Muestra un snackbar informativo
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = _defaultDuration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _show(
      context: context,
      message: message,
      type: _SnackbarType.info,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Muestra un snackbar de advertencia
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = _defaultDuration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _show(
      context: context,
      message: message,
      type: _SnackbarType.warning,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required _SnackbarType type,
    Duration duration = _defaultDuration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    // Remover snackbar anterior si existe
    ScaffoldMessenger.of(context).clearSnackBars();

    final theme = Theme.of(context);
    final colorScheme = _getColorScheme(type, theme);

    final snackBar = SnackBar(
      content: _SnackbarContent(
        message: message,
        type: type,
        colorScheme: colorScheme,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      // margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
      action: onAction != null && actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: colorScheme.onPrimary,
              onPressed: onAction,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static _SnackbarColorScheme _getColorScheme(
    _SnackbarType type,
    ThemeData theme,
  ) {
    switch (type) {
      case _SnackbarType.success:
        return _SnackbarColorScheme(
          backgroundColor: const Color(0xFF4CAF50),
          onPrimary: Colors.white,
          icon: Icons.check_circle_outline,
        );
      case _SnackbarType.error:
        return _SnackbarColorScheme(
          backgroundColor: const Color(0xFFF44336),
          onPrimary: Colors.white,
          icon: Icons.error_outline,
        );
      case _SnackbarType.warning:
        return _SnackbarColorScheme(
          backgroundColor: const Color(0xFFFF9800),
          onPrimary: Colors.white,
          icon: Icons.warning_outlined,
        );
      case _SnackbarType.info:
        return _SnackbarColorScheme(
          backgroundColor: theme.colorScheme.primary,
          onPrimary: Colors.white,
          icon: Icons.info_outline,
        );
    }
  }
}

class _SnackbarContent extends StatelessWidget {
  final String message;
  final _SnackbarType type;
  final _SnackbarColorScheme colorScheme;

  const _SnackbarContent({
    required this.message,
    required this.type,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.backgroundColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(colorScheme.icon, color: colorScheme.onPrimary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .slideX(
          begin: 1.0,
          end: 0.0,
          duration: 300.ms,
          curve: Curves.easeOutBack,
        )
        .fade(begin: 0.0, end: 1.0, duration: 300.ms);
  }
}

enum _SnackbarType { success, error, warning, info }

class _SnackbarColorScheme {
  final Color backgroundColor;
  final Color onPrimary;
  final IconData icon;

  const _SnackbarColorScheme({
    required this.backgroundColor,
    required this.onPrimary,
    required this.icon,
  });
}
