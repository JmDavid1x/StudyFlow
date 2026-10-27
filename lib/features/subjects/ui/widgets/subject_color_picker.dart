import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Selector del color de la materia (Figma 09), con los colores de
/// `SfColors.subjectColors`. La elegida lleva un anillo blanco.
class SubjectColorPicker extends StatelessWidget {
  const SubjectColorPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// Posición del color elegido en `SfColors.subjectColors`.
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SfSpacing.xxs,
      runSpacing: SfSpacing.xxs,
      children: [
        for (var i = 0; i < SfColors.subjectColors.length; i++)
          Semantics(
            button: true,
            selected: i == selected,
            label: 'Color ${i + 1}',
            child: InkResponse(
              onTap: () => onChanged(i),
              child: SizedBox.square(
                dimension: SfSpacing.xl + SfSpacing.sm,
                child: Center(
                  child: Container(
                    width: SfSpacing.xl + SfSpacing.xs,
                    height: SfSpacing.xl + SfSpacing.xs,
                    padding: const EdgeInsets.all(SfSpacing.xxs),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i == selected ? SfColors.textPrimary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: SfColors.subjectColors[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
