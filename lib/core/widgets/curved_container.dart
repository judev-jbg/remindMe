// lib/core/widgets/advanced_curved_transition.dart

import 'package:flutter/material.dart';

class AdvancedCurvedTransition extends StatelessWidget {
  final Widget child;
  final Color topColor;
  final Color bottomColor;
  final double curveHeight;

  const AdvancedCurvedTransition({
    Key? key,
    required this.child,
    required this.topColor,
    required this.bottomColor,
    this.curveHeight = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, curveHeight),
            painter: AdvancedCurvedPainter(
              topColor: topColor,
              bottomColor: bottomColor,
            ),
          ),
        ),
      ],
    );
  }
}

class AdvancedCurvedPainter extends CustomPainter {
  final Color topColor;
  final Color bottomColor;

  AdvancedCurvedPainter({required this.topColor, required this.bottomColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Primera curva (más suave)
    final paint1 = Paint()
      ..color = topColor
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    path1.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.4);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    canvas.drawPath(path1, paint1);

    // Segunda curva (más pronunciada)
    final paint2 = Paint()
      ..color = bottomColor
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width,
      size.height * 0.7,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
