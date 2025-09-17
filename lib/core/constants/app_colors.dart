// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

/// Colores base de la aplicación inspirados en diseño moderno minimalista
class AppColors {
  AppColors._();

  // Colores primarios
  static const Color primary = Color(0xFF667EEA);
  static const Color primaryVariant = Color(0xFF764BA2);
  static const Color secondary = Color(0xFF42A5F5);
  static const Color secondaryVariant = Color(0xFF1E88E5);

  // Colores de superficie - Light theme
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);

  // Colores de superficie - Dark theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);

  // Colores de texto
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);

  // Colores especiales para timeline
  static const Color todayEmphasis = Color(0xFFE8F4FD);
  static const Color todayEmphasisDark = Color(0xFF1A365D);
  static const Color pastSubtle = Color(0xFFF8F9FA);
  static const Color pastSubtleDark = Color(0xFF2D2D2D);

  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Colores para notificaciones
  static const Color unreadLight = Color(0xFFFFF3E0);
  static const Color unreadDark = Color(0xFF2E1500);
}
