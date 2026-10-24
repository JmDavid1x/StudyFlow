import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';

/// Barra de progreso: progreso semanal, consultas usadas, porcentaje evaluado.
class SfProgressBar extends StatelessWidget {
  const SfProgressBar({
    super.key,
    required this.value,
    this.color = SfColors.primary,
    this.height = 8,
  });

  /// Entre 0 y 1.
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1).toDouble(),
        minHeight: height,
        color: color,
        backgroundColor: SfColors.border,
      ),
    );
  }
}

/// Anillo de progreso con un contenido al centro (la nota actual de una materia).
class SfProgressRing extends StatelessWidget {
  const SfProgressRing({
    super.key,
    required this.value,
    required this.child,
    this.size = 120,
    this.strokeWidth = 10,
    this.color = SfColors.primaryLight,
  });

  final double value;
  final Widget child;
  final double size;
  final double strokeWidth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value.clamp(0, 1).toDouble(),
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: SfColors.border,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
