import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/subjects/ui/widgets/grade_component_row.dart';
import 'package:studyflow/features/subjects/ui/widgets/subject_grade_card.dart';
import 'package:studyflow/features/subjects/ui/widgets/subjects_prototype_data.dart';

/// Detalle de una materia (Figma 22).
///
/// Recibe la materia como argumento de la ruta. Muestra la nota actual contra
/// la meta, cómo se calcula la nota y las actividades.
class SubjectDetailScreen extends StatelessWidget {
  const SubjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subject = subjectFromArguments(ModalRoute.of(context)?.settings.arguments);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Materia'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  SfSpacing.screen,
                  SfSpacing.xs,
                  SfSpacing.screen,
                  SfSpacing.lg,
                ),
                children: [
                  Text(subject.name, style: SfTypography.h1),
                  const SizedBox(height: SfSpacing.xxs),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: SfSpacing.md,
                        color: SfColors.textSecondary,
                      ),
                      const SizedBox(width: SfSpacing.xxs),
                      Expanded(
                        child: Text(
                          '${subject.professor} · ${subject.scheduleStart}',
                          style: SfTypography.caption,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SfSpacing.md),
                  SubjectGradeCard(subject: subject),
                  const SizedBox(height: SfSpacing.sm),
                  SfButton(
                    label: 'Registrar nota',
                    variant: SfButtonVariant.secondary,
                    icon: Icons.star_outline_rounded,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.registerGrade,
                      arguments: subject,
                    ),
                  ),
                  const SizedBox(height: SfSpacing.lg),
                  Text('Cómo se calcula tu nota', style: SfTypography.h2),
                  const SizedBox(height: SfSpacing.xs),
                  for (final component in prototypeComponents)
                    GradeComponentRow(component: component),
                  const SizedBox(height: SfSpacing.lg),
                  Text('Actividades', style: SfTypography.h2),
                  const SizedBox(height: SfSpacing.sm),
                  if (prototypeActivities.isEmpty)
                    const SfEmptyState(
                      icon: Icons.checklist_rounded,
                      title: 'Aún no hay actividades',
                      message: 'Agrega una tarea de esta materia para verla aquí.',
                    )
                  else
                    for (final activity in prototypeActivities) ...[
                      SfTaskTile(
                        title: activity.title,
                        subtitle: activity.listDetail,
                        subjectColor: subject.color,
                        done: activity.done,
                        trailing: activity.recent
                            ? const SfBadge(label: 'Recién completada', tone: SfTone.success)
                            : null,
                      ),
                      const SizedBox(height: SfSpacing.sm),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
