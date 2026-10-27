import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form_data.dart';

/// Selector de la parte de la nota (Figma 14): tres tarjetas angostas con el
/// porcentaje arriba y el nombre abajo. SfOptionCards pone el texto al lado
/// del círculo y en tres columnas no cabe, por eso esta versión compacta.
class GradePartSelector extends StatelessWidget {
  const GradePartSelector({
    super.key,
    required this.parts,
    required this.selected,
    required this.onChanged,
  });

  final List<GradePart> parts;
  final GradePart? selected;
  final ValueChanged<GradePart> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) const SizedBox(width: SfSpacing.xs),
          Expanded(
            child: _GradePartCard(
              part: parts[i],
              selected: parts[i] == selected,
              onTap: () => onChanged(parts[i]),
            ),
          ),
        ],
      ],
    );
  }
}

/// Una tarjeta: porcentaje arriba con su círculo de selección, nombre abajo.
class _GradePartCard extends StatelessWidget {
  const _GradePartCard({required this.part, required this.selected, required this.onTap});

  final GradePart part;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.md);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? SfColors.primarySoft : SfColors.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.all(SfSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? SfColors.primary : SfColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${part.weight} %',
                        style: SfTypography.number.copyWith(color: SfColors.primaryLight),
                      ),
                    ),
                    SfRadioDot(selected: selected),
                  ],
                ),
                const SizedBox(height: SfSpacing.xxs),
                Text(
                  part.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SfTypography.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
