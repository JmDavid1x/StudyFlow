import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/ui/widgets/subjects_prototype_data.dart';

/// Fila de una materia agregada (Figma 08): barra con el color de la materia,
/// nombre, horario y créditos.
class SubjectSetupTile extends StatelessWidget {
  const SubjectSetupTile({super.key, required this.subject, this.onTap});

  final PrototypeSubject subject;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: SfSpacing.xxs,
              decoration: BoxDecoration(
                color: subject.color,
                borderRadius: BorderRadius.circular(SfRadius.sm),
              ),
            ),
            const SizedBox(width: SfSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(subject.name, style: SfTypography.bodyStrong),
                  const SizedBox(height: SfSpacing.xxs),
                  Text(
                    '${subject.schedule} · ${subject.credits} créditos',
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
