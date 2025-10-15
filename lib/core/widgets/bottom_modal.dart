import 'package:flutter/material.dart';

/// Modal inferior reutilizable con diseño moderno y animaciones fluidas
/// Soporta drag to dismiss y ocupa el porcentaje especificado de la pantalla
class BottomModal extends StatefulWidget {
  final Widget child;
  final double heightPercentage;
  final bool isDismissible;
  final VoidCallback? onDismiss;
  final Color? backgroundColor;
  final double borderRadius;

  const BottomModal({
    super.key,
    required this.child,
    this.heightPercentage = 0.8,
    this.isDismissible = true,
    this.onDismiss,
    this.backgroundColor,
    this.borderRadius = 24,
  });

  @override
  State<BottomModal> createState() => _BottomModalState();

  /// Método estático para mostrar el modal
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double heightPercentage = 0.8,
    bool isDismissible = true,
    VoidCallback? onDismiss,
    Color? backgroundColor,
    double borderRadius = 24,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      builder: (context) => BottomModal(
        heightPercentage: heightPercentage,
        isDismissible: isDismissible,
        onDismiss: onDismiss,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}

class _BottomModalState extends State<BottomModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    widget.onDismiss?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    // Altura máxima del modal (sin contar el teclado)
    final maxHeight = screenHeight * widget.heightPercentage;

    return GestureDetector(
      onTap: widget.isDismissible ? _handleDismiss : null,
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {}, // Prevenir cierre al tocar el modal
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: Offset(0, maxHeight * (1 - _animation.value)),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          widget.backgroundColor ?? theme.colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(widget.borderRadius),
                        topRight: Radius.circular(widget.borderRadius),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    // Agregar padding bottom para el teclado
                    padding: EdgeInsets.only(bottom: keyboardHeight),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle indicator
                        if (widget.isDismissible) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ] else
                          const SizedBox(height: 24),

                        // Content - ahora flexible en lugar de expandido
                        Flexible(
                          child: SingleChildScrollView(child: widget.child),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
