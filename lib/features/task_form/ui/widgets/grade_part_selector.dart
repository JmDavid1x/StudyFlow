import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';

/// Selector de la parte de la nota (Figma 14): tarjetas angostas con el
/// porcentaje arriba y el nombre abajo, tres por fila. Las partes son los
/// componentes de nota de la materia elegida (Talleres 30 %, Proyecto 40 %...).
class GradePartSelector extends StatelessWidget {
  const GradePartSelector({
    super.key,
    required this.parts,
    required this.selected,
    required this.onChanged,
  });

  static const _porFila = 3;

  final List<ComponenteNota> parts;
  final ComponenteNota? selected;
  final ValueChanged<ComponenteNota> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = SfSpacing.xs;
        final width = (constraints.maxWidth - gap * (_porFila - 1)) / _porFila;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final part in parts)
              SizedBox(
                width: width,
                child: _GradePartCard(
                  part: part,
                  selected: part.id == selected?.id,
                  onTap: () => onChanged(part),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Una tarjeta: porcentaje arriba con su círculo de selección, nombre abajo.
class _GradePartCard extends StatelessWidget {
  const _GradePartCard({
    required this.part,
    required this.selected,
    required this.onTap,
  });

  final ComponenteNota part;
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
                        '${part.porcentaje.round()} %',
                        style: SfTypography.number.copyWith(
                          color: SfColors.primaryLight,
                        ),
                      ),
                    ),
                    SfRadioDot(selected: selected),
                  ],
                ),
                const SizedBox(height: SfSpacing.xxs),
                Text(
                  part.nombre,
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
