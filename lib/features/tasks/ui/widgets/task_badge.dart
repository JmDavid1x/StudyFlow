import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';

/// Insignia de una actividad pendiente en una lista: "Examen", "En progreso" o
/// su prioridad, en ese orden (Figma 17).
class TaskBadge extends StatelessWidget {
  const TaskBadge({super.key, required this.actividad});

  final Actividad actividad;

  @override
  Widget build(BuildContext context) {
    if (actividad.esExamen) return const SfBadge(label: 'Examen', tone: SfTone.warning);
    if (actividad.estado == EstadoActividad.enProgreso) {
      return const SfBadge(label: 'En progreso', tone: SfTone.primary);
    }
    return SfBadge.priority(actividad.prioridad.db);
  }
}
