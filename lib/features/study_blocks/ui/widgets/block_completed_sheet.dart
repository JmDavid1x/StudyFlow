import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/demo_agenda.dart';

/// S5 Bloque completado. Confirma el bloque y aclara que la tarea sigue
/// abierta hasta que se marque como entregada.
///
/// [closeScreen] es true cuando se abre desde Bloque de estudio: el botón
/// "Volver al calendario" cierra la hoja y esa pantalla. Desde la pestaña
/// Calendario va en false: el botón dice "Listo" y solo cierra la hoja, para
/// no sacar al usuario de la app principal.
Future<void> showBlockCompletedSheet(
  BuildContext context,
  AgendaItem block, {
  bool closeScreen = true,
}) {
  final task = block.task!;
  final count = DemoAgenda.blocksFor(task);
  final message = count > 1
      ? 'Ya hiciste los $count bloques que tenías para "${task.title}".'
      : 'Ya hiciste el bloque que tenías para "${task.title}".';

  return showSfBottomSheet<void>(
    context,
    builder: (sheetContext) => SfResultSheet(
      title: 'Bloque completado',
      message: message,
      primaryLabel: 'Ver la tarea',
      onPrimary: () {
        Navigator.pop(sheetContext);
        Navigator.pushNamed(
          context,
          task.isExam ? AppRoutes.examDetail : AppRoutes.taskDetail,
          arguments: task,
        );
      },
      secondaryLabel: closeScreen ? 'Volver al calendario' : 'Listo',
      onSecondary: () {
        Navigator.pop(sheetContext);
        if (closeScreen) Navigator.pop(context);
      },
      child: SfCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Estado de la tarea', style: SfTypography.bodyStrong)),
                const SfBadge(label: 'En progreso', tone: SfTone.primary),
              ],
            ),
            const SizedBox(height: SfSpacing.xs),
            Text(
              'La tarea sigue abierta: márcala como completada cuando la entregues.',
              style: SfTypography.caption,
            ),
          ],
        ),
      ),
    ),
  );
}
