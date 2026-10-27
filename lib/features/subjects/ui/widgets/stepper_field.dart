import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Campo con botones menos y más y un valor al centro: créditos, nota,
/// porcentaje. Reemplaza al teclado para datos que se eligen.
/// Si un botón recibe `null`, se ve deshabilitado (llegó al límite).
class StepperField extends StatelessWidget {
  const StepperField({
    super.key,
    required this.icon,
    required this.label,
    required this.onDecrement,
    required this.onIncrement,
    required this.decrementTooltip,
    required this.incrementTooltip,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final String decrementTooltip;
  final String incrementTooltip;

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
            tooltip: decrementTooltip,
            onPressed: onDecrement,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: SfSpacing.md, color: SfColors.textSecondary),
                const SizedBox(width: SfSpacing.xxs),
                Text(label, style: SfTypography.bodyStrong),
              ],
            ),
          ),
          _StepButton(
            icon: Icons.add,
            tooltip: incrementTooltip,
            onPressed: onIncrement,
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
