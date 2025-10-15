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
  static const Color onStaticPrimary = Color(0xFFF8F8F8);

  // Colores de superficie - Light theme
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLight = Color(0xFFE9E9E9);
  static const Color surfaceContainerLowLight = Color(0xFFF5F5F5);
  static const Color surfaceVariantLight = Color(0xFFF0F0F0);

  // Colores de superficie - Dark theme
  static const Color backgroundDark = Color(0xFF313131);
  static const Color surfaceDark = Color(0xFF313131);
  static const Color surfaceContainerDark = Color(0xFF424242);
  static const Color surfaceContainerLowDark = Color(0xFF3D3D3D);
  static const Color surfaceVariantDark = Color(0xFF414141);

  // Colores de texto
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);

  // Colores especiales para timeline
  static const Color todayEmphasisLight = Color(0xFFE9F4FD);
  static const Color todayEmphasisDark = Color(0xFF344A5C);

  // Colores de estado
  static const Color success = Color(0xFF66CA6A);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFFA584C);
  static const Color info = Color(0xFF2196F3);

  // Colores para notificaciones
  static const Color unreadLight = Color(0xFFF4E9FD);
  static const Color unreadDark = Color(0xFF52576B);
}
