import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';

/// S5 Bloque completado. Confirma el bloque y aclara que la tarea sigue
/// abierta hasta que se marque como entregada.
///
/// Desde Bloque de estudio llega [actividad]: el botón principal es "Ver la
/// tarea" y "Volver al calendario" cierra la hoja y esa pantalla. Desde la
/// pestaña Calendario no llega: el botón es "Listo" y solo cierra la hoja,
/// para no sacar al usuario de la app principal.
Future<void> showBlockCompletedSheet(
  BuildContext context,
  BloqueEstudio bloque, {
  Actividad? actividad,
}) {
  final titulo = actividad?.titulo ?? bloque.actividadTitulo;
  return showSfBottomSheet<void>(
    context,
    builder: (sheetContext) => SfResultSheet(
      title: 'Bloque completado',
      message: titulo == null
          ? 'Ya hiciste este bloque de estudio.'
          : 'Ya hiciste este bloque para "$titulo".',
      primaryLabel: actividad == null ? 'Listo' : 'Ver la tarea',
      onPrimary: () {
        Navigator.pop(sheetContext);
        if (actividad != null) {
          Navigator.pushReplacementNamed(
            context,
            actividad.esExamen ? AppRoutes.examDetail : AppRoutes.taskDetail,
            arguments: actividad,
          );
        }
      },
      secondaryLabel: actividad == null ? null : 'Volver al calendario',
      onSecondary: () {
        Navigator.pop(sheetContext);
        Navigator.pop(context);
      },
      child: SfCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Estado de la tarea',
                    style: SfTypography.bodyStrong,
                  ),
                ),
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
