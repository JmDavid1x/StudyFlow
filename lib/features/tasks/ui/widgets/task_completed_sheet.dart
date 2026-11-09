import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/tasks/domain/textos_actividad.dart';
import 'package:studyflow/features/tasks/ui/bloc/task_detail_cubit.dart';

/// "Quitamos de tu calendario el bloque que te quedaba para esta tarea (mar 22, 10:00 a. m.)."
String? removedBlocksNote(List<BloqueEstudio> bloques) {
  if (bloques.isEmpty) return null;
  if (bloques.length > 1) {
    return 'Quitamos de tu calendario los ${bloques.length} bloques que te quedaban para esta tarea.';
  }
  final inicio = bloques.first.inicio;
  return 'Quitamos de tu calendario el bloque que te quedaba para esta tarea (${diaCorto(inicio)}, ${hora(inicio)}).';
}

/// Abre S1 Tarea completada: cómo va la materia y qué bloque se quitó.
Future<void> showTaskCompletedSheet(BuildContext context, Actividad actividad, ResumenCompletada resumen) {
  final hechas = resumen.hechas;
  final total = resumen.total;
  final progress = hechas == null || total == null || total == 0 ? null : hechas / total;
  final note = removedBlocksNote(resumen.bloquesQuitados);
  final subject = actividad.materiaNombre ?? '';

  return showSfBottomSheet<void>(
    context,
    builder: (sheetContext) => SfResultSheet(
      title: resumen.aTiempo == null ? '¡Tarea completada!' : '¡La completaste a tiempo!',
      message: resumen.aTiempo ?? 'Quedó en tus tareas completadas.',
      primaryLabel: 'Ver progreso de la materia',
      onPrimary: () {
        Navigator.pop(sheetContext);
        Navigator.pushNamed(context, AppRoutes.subjectDetail);
      },
      secondaryLabel: 'Volver al inicio',
      onSecondary: () =>
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false, arguments: AppTabs.home),
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
                            Expanded(child: Text(subject, style: SfTypography.bodyStrong)),
                            const SizedBox(width: SfSpacing.xs),
                            Flexible(
                              child: Text(
                                '$hechas de $total actividades',
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
                        const Icon(
                          Icons.event_outlined,
                          size: SfSpacing.lg - SfSpacing.xxs,
                          color: SfColors.primaryLight,
                        ),
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
