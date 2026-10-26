import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';

/// Datos del prototipo que no están en DemoData y solo usan las pantallas de
/// tareas. Salen tal cual de Figma; en el Sprint 2 vienen de Supabase.
abstract final class TaskExtras {
  /// La tarea vencida de Figma 17 (sección Vencidas).
  static const overdue = DemoTask(
    title: 'Quiz 3: widgets',
    subject: 'Aplicaciones Móviles',
    color: SfColors.primaryLight,
    due: 'venció ayer',
    priority: 'alta',
  );

  static const _inProgress = {'Prototipo flujo principal'};

  /// Tareas que el estudiante ya empezó ("En progreso" en Figma 17).
  static bool isInProgress(DemoTask task) => _inProgress.contains(task.title);
}
