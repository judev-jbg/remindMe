// lib/core/constants/app_gradients.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gradientes inspirados en las referencias de diseño moderno
class AppGradients {
  AppGradients._();

  // Gradiente principal - Inspirado en imagen 1 (Diet app)
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryVariant],
  );

  // Gradientes para cards de eventos - Inspirado en imagen 2 (Chat app)
  static const LinearGradient darkCard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
  );

  // Gradientes vibrantes - Inspirado en imagen 3 (Curves app)
  static const LinearGradient vibrantOrange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8A80), Color(0xFFFF5722)],
  );

  static const LinearGradient vibrantBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
  );

  static const LinearGradient vibrantPink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEC407A), Color(0xFFE91E63)],
  );

  static const LinearGradient vibrantGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
  );

  static const LinearGradient vibrantPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFAB47BC), Color(0xFF9C27B0)],
  );

  // Gradientes suaves para backgrounds
  static const LinearGradient softBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
  );

  static const LinearGradient darkBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF121212), Color(0xFF000000)],
  );

  /// Obtiene un gradiente aleatorio para las cards de eventos
  static LinearGradient getEventCardGradient(int index) {
    final gradients = [
      vibrantBlue,
      vibrantOrange,
      vibrantPink,
      vibrantGreen,
      vibrantPurple,
      primary,
    ];
    return gradients[index % gradients.length];
  }
}
