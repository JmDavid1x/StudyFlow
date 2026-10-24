import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Selector de porcentaje con botones menos y más (Figma 14: "Valor en la
/// nota"). Se elige tocando, nunca con el teclado.
class PercentStepper extends StatelessWidget {
  const PercentStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 5,
    this.max = 100,
    this.step = 5,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;

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
          SfIconButton(
            icon: Icons.remove,
            tooltip: 'Bajar porcentaje',
            onPressed: value - step >= min ? () => onChanged(value - step) : null,
          ),
          Expanded(
            child: Text('$value %', textAlign: TextAlign.center, style: SfTypography.number),
          ),
          SfIconButton(
            icon: Icons.add,
            tooltip: 'Subir porcentaje',
            onPressed: value + step <= max ? () => onChanged(value + step) : null,
          ),
        ],
      ),
    );
  }
}
