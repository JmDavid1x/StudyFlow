import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/ui/widgets/formato_materias.dart';

/// Resumen de la pestaña Materias (Figma 21): promedio del semestre y
/// cantidad de materias.
class SemesterAverageCard extends StatelessWidget {
  const SemesterAverageCard({
    super.key,
    required this.promedio,
    required this.cantidadMaterias,
  });

  /// Nulo si aún no hay notas.
  final double? promedio;
  final int cantidadMaterias;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      highlighted: true,
      child: Row(
        children: [
          Container(
            width: SfSpacing.xl + SfSpacing.xs,
            height: SfSpacing.xl + SfSpacing.xs,
            decoration: BoxDecoration(
              color: SfColors.primary,
              borderRadius: BorderRadius.circular(SfRadius.md),
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              color: SfColors.textPrimary,
            ),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Promedio del semestre', style: SfTypography.caption),
                Text(
                  promedio == null
                      ? 'Sin notas aún'
                      : '${notaTexto(promedio)} de 5.0',
                  style: SfTypography.h2,
                ),
              ],
            ),
          ),
          SfBadge(
            label: cantidadMaterias == 1
                ? '1 materia'
                : '$cantidadMaterias materias',
            tone: SfTone.primary,
          ),
        ],
      ),
    );
  }
}
