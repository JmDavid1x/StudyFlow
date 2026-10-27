import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Botón de borde punteado para agregar algo a una lista: "Agregar materia".
///
/// Es una acción secundaria, así que no compite con el botón principal de la
/// pantalla.
class DashedAddButton extends StatelessWidget {
  const DashedAddButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.lg);
    return Semantics(
      button: true,
      label: label,
      child: CustomPaint(
        painter: const _DashedBorderPainter(
          color: SfColors.primary,
          radius: SfRadius.lg,
          dash: SfSpacing.xs,
          gap: SfSpacing.xxs,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: SfSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: SfSpacing.lg - SfSpacing.xxs, color: SfColors.primaryLight),
                  const SizedBox(width: SfSpacing.xs),
                  Text(
                    label,
                    style: SfTypography.bodyStrong.copyWith(color: SfColors.primaryLight),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dash,
    required this.gap,
  });

  static const _strokeWidth = 1.5;

  final Color color;
  final double radius;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final rect = (Offset.zero & size).deflate(_strokeWidth / 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      dash != oldDelegate.dash ||
      gap != oldDelegate.gap;
}
