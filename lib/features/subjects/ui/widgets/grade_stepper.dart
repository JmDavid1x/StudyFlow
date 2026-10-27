import 'package:flutter/material.dart';

import 'package:studyflow/features/subjects/ui/widgets/stepper_field.dart';

/// Selector de nota de 0.0 a 5.0 con botones menos y más (Figma 23 y 09).
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
    return StepperField(
      icon: Icons.star_outline_rounded,
      label: (tenths / 10).toStringAsFixed(1),
      decrementTooltip: 'Bajar nota',
      incrementTooltip: 'Subir nota',
      onDecrement: tenths > _min ? () => onChanged(tenths - 1) : null,
      onIncrement: tenths < _max ? () => onChanged(tenths + 1) : null,
    );
  }
}
