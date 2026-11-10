import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/ui/widgets/formato_materias.dart';

/// Fila de una materia agregada (Figma 08): barra con el color de la materia,
/// nombre, horario y créditos.
class SubjectSetupTile extends StatelessWidget {
  const SubjectSetupTile({super.key, required this.materia, this.onTap});

  final Materia materia;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final horario = horarioTexto(materia.horarios);
    final creditos =
        '${materia.creditos} ${materia.creditos == 1 ? 'crédito' : 'créditos'}';

    return SfCard(
      onTap: onTap,
      child: IntrinsicHeight(
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
                  const SizedBox(height: SfSpacing.xxs),
                  Text(
                    horario == null ? creditos : '$horario · $creditos',
                    style: SfTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: SfSpacing.xs),
            const Icon(Icons.chevron_right, color: SfColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
