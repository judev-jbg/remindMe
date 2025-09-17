// lib/core/widgets/curved_container.dart

import 'package:flutter/material.dart';

/// Container con diseño de curvas fluidas inspirado en la imagen 3
/// Soporta gradientes personalizados y altura de curva ajustable
class CurvedContainer extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double curveHeight;
  final EdgeInsetsGeometry? padding;
  final bool isInverted;

  const CurvedContainer({
    super.key,
    required this.child,
    required this.gradient,
    this.curveHeight = 80,
    this.padding,
    this.isInverted = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CurvePainter(
        gradient: gradient,
        curveHeight: curveHeight,
        isInverted: isInverted,
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}

/// Painter personalizado para crear las curvas fluidas
class CurvePainter extends CustomPainter {
  final Gradient gradient;
  final double curveHeight;
  final bool isInverted;

  CurvePainter({
    required this.gradient,
    required this.curveHeight,
    required this.isInverted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final path = Path();

    if (isInverted) {
      // Curva invertida (cóncava)
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height - curveHeight)
        ..quadraticBezierTo(
          size.width * 0.75,
          size.height - curveHeight * 1.2,
          size.width * 0.5,
          size.height - curveHeight * 0.6,
        )
        ..quadraticBezierTo(
          size.width * 0.25,
          size.height,
          0,
          size.height - curveHeight,
        )
        ..close();
    } else {
      // Curva normal (convexa)
      path
        ..moveTo(0, curveHeight)
        ..quadraticBezierTo(
          size.width * 0.25,
          0,
          size.width * 0.5,
          curveHeight * 0.6,
        )
        ..quadraticBezierTo(
          size.width * 0.75,
          curveHeight * 1.2,
          size.width,
          curveHeight * 0.8,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is CurvePainter &&
        (oldDelegate.gradient != gradient ||
            oldDelegate.curveHeight != curveHeight ||
            oldDelegate.isInverted != isInverted);
  }
}
