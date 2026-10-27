import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Selector de nota de 0.0 a 5.0 con botones menos y más (Figma 23).
/// No abre el teclado. Trabaja en décimas (46 = 4.6) para no acumular
/// errores de decimales.
class GradeStepper extends StatelessWidget {
  const GradeStepper({super.key, required this.tenths, required this.onChanged});

  static const _min = 0;
  static const _max = 50;

  final int tenths;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SfSpacing.xxs),
      decoration: BoxDecoration(
        color: SfColors.surface,
        borderRadius: BorderRadius.circular(SfRadius.md),
        border: Border.all(color: SfColors.border),
      ),
      child: Row(
        children: [
          _StepButton(
            icon: Icons.remove,
            tooltip: 'Bajar nota',
            onPressed: tenths > _min ? () => onChanged(tenths - 1) : null,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_outline_rounded,
                  size: SfSpacing.md,
                  color: SfColors.textSecondary,
                ),
                const SizedBox(width: SfSpacing.xxs),
                Text((tenths / 10).toStringAsFixed(1), style: SfTypography.bodyStrong),
              ],
            ),
          ),
          _StepButton(
            icon: Icons.add,
            tooltip: 'Subir nota',
            onPressed: tenths < _max ? () => onChanged(tenths + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.sm);
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onPressed == null ? 0.4 : 1,
        child: Material(
          color: SfColors.primarySoft,
          borderRadius: radius,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: SizedBox.square(
              dimension: SfSpacing.xl + SfSpacing.sm,
              child: Icon(icon, color: SfColors.primaryLight),
            ),
          ),
        ),
      ),
    );
  }
}
