import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_extras.dart';

/// Abre S1 Tarea completada: cómo va la materia y qué bloque se quitó.
Future<void> showTaskCompletedSheet(BuildContext context, DemoTask task) {
  final details = TaskExtras.of(task);
  final progress = details.subjectProgress;
  final note = details.removedBlockNote;

  return showSfBottomSheet<void>(
    context,
    builder: (sheetContext) => SfResultSheet(
      title: details.completedMessage == null ? '¡Tarea completada!' : '¡La completaste a tiempo!',
      message: details.completedMessage ?? 'Quedó en tus tareas completadas.',
      primaryLabel: 'Ver progreso de la materia',
      onPrimary: () {
        Navigator.pop(sheetContext);
        Navigator.pushNamed(context, AppRoutes.subjectDetail);
      },
      secondaryLabel: 'Volver al inicio',
      onSecondary: () => Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (_) => false,
        arguments: AppTabs.home,
      ),
      child: progress == null && note == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (progress != null)
                  SfCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(task.subject, style: SfTypography.bodyStrong)),
                            const SizedBox(width: SfSpacing.xs),
                            Flexible(
                              child: Text(
                                details.subjectProgressLabel ?? '',
                                textAlign: TextAlign.end,
                                style: SfTypography.caption,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: SfSpacing.sm),
                        SfProgressBar(value: progress),
                      ],
                    ),
                  ),
                if (progress != null && note != null) const SizedBox(height: SfSpacing.sm),
                if (note != null)
                  SfCard(
                    padding: const EdgeInsets.all(SfSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.event_outlined, size: SfSpacing.lg - SfSpacing.xxs, color: SfColors.primaryLight),
                        const SizedBox(width: SfSpacing.sm),
                        Expanded(child: Text(note, style: SfTypography.caption)),
                      ],
                    ),
                  ),
              ],
            ),
    ),
  );
}
