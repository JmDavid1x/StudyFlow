import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_extras.dart';

/// Insignia de una tarea pendiente en una lista: "Examen", "En progreso" o su
/// prioridad, en ese orden (Figma 17).
class TaskBadge extends StatelessWidget {
  const TaskBadge({super.key, required this.task});

  final DemoTask task;

  @override
  Widget build(BuildContext context) {
    if (task.isExam) return const SfBadge(label: 'Examen', tone: SfTone.warning);
    if (TaskExtras.isInProgress(task)) return const SfBadge(label: 'En progreso', tone: SfTone.primary);
    return SfBadge.priority(task.priority);
  }
}
