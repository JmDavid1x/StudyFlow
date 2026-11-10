import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/domain/resumen_semestre.dart';
import 'package:studyflow/features/subjects/ui/widgets/formato_materias.dart';

/// Tarjeta de una materia en la pestaña Materias (Figma 21): color, nombre,
/// profesor, nota actual, meta y barra de avance hacia 5.0.
class SubjectProgressCard extends StatelessWidget {
  const SubjectProgressCard({super.key, required this.item, this.onTap});

  static const _maxGrade = 5.0;

  final MateriaConNota item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final materia = item.materia;
    final nota = item.resumen.notaAcumulada;
    final meta = materia.metaNota;

    return SfCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: SfSpacing.xxs,
                  decoration: BoxDecoration(
                    color: materia.color,
                    borderRadius: BorderRadius.circular(SfRadius.sm),
                  ),
                ),
                const SizedBox(width: SfSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(materia.nombre, style: SfTypography.bodyStrong),
                      if (materia.profesor != null) ...[
                        const SizedBox(height: SfSpacing.xxs),
                        Text(materia.profesor!, style: SfTypography.caption),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: SfSpacing.xs),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(notaTexto(nota), style: SfTypography.h2),
                    Text(
                      meta == null ? 'sin meta' : 'meta ${notaTexto(meta)}',
                      style: SfTypography.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: SfSpacing.sm),
          SfProgressBar(
            value: ((nota ?? 0) / _maxGrade).clamp(0.0, 1.0),
            color: materia.color,
          ),
        ],
      ),
    );
  }
}
