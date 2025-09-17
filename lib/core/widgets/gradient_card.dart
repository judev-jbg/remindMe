// lib/core/widgets/gradient_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Card con gradiente inspirada en el diseño moderno de las referencias
/// Incluye animaciones suaves y efectos de glassmorphism sutil
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool isInteractive;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.boxShadow,
    this.onTap,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

    Widget cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? defaultShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(padding: padding!, child: child),
        ),
      ),
    );

    if (isInteractive) {
      return cardContent
          .animate()
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.02, 1.02),
            duration: 150.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.02, 1.02),
            end: const Offset(1.0, 1.0),
            duration: 150.ms,
            curve: Curves.easeOut,
          );
    }

    return cardContent;
  }
}
