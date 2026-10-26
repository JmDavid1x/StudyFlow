import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';

/// Un bloque de estudio en el detalle de una tarea o examen (Figma 18 y 29).
class TaskBlock {
  const TaskBlock({required this.title, required this.when, this.done = false});

  final String title;

  /// "Mar 22 · 10:00 a. m. – 12:00 p. m."
  final String when;
  final bool done;
}

/// Lo que se ve en el detalle de una actividad y no está en DemoData.
/// Lo que es null no se muestra: no se inventan datos.
class TaskDetails {
  const TaskDetails({
    this.dueLabel,
    this.timeLeft,
    this.channel,
    this.place,
    this.gradePart,
    this.reminder,
    this.blocks = const [],
    this.completedMessage,
    this.subjectProgressLabel,
    this.subjectProgress,
    this.removedBlockNote,
    this.overdueMessage,
  });

  /// "Mié 23/09 · 11:59 p. m."
  final String? dueLabel;

  /// "Faltan 2 días"
  final String? timeLeft;

  /// Canal de entrega de una tarea: "INTU".
  final String? channel;

  /// Lugar de un examen: "Salón 302".
  final String? place;

  /// "Proyecto · 15 %"
  final String? gradePart;
  final String? reminder;
  final List<TaskBlock> blocks;

  // Lo que muestra S1 Tarea completada.
  final String? completedMessage;
  final String? subjectProgressLabel;
  final double? subjectProgress;
  final String? removedBlockNote;

  /// Lo que muestra S8 Tarea vencida.
  final String? overdueMessage;
}

/// "hoy 11:59 p. m." → "Hoy 11:59 p. m."
String sentenceCase(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

/// Datos del prototipo que no están en DemoData y solo usan las pantallas de
/// tareas. Salen tal cual de Figma; en el Sprint 2 vienen de Supabase.
abstract final class TaskExtras {
  /// La tarea vencida de Figma 17 y S8.
  static const overdue = DemoTask(
    title: 'Quiz 3: widgets',
    subject: 'Aplicaciones Móviles',
    color: SfColors.primaryLight,
    due: 'venció ayer',
    priority: 'alta',
  );

  /// La tarea que se ve en Figma 18. Se muestra si llegan sin argumento.
  static DemoTask get prototypeTask => DemoData.tasks.firstWhere((task) => task.title == 'Prototipo flujo principal');

  /// El examen que se ve en Figma 29. Se muestra si llegan sin argumento.
  static DemoTask get prototypeExam => DemoData.tasks.firstWhere((task) => task.isExam);

  static const _inProgress = {'Prototipo flujo principal'};

  /// Tareas que el estudiante ya empezó ("En progreso" en Figma 17).
  static bool isInProgress(DemoTask task) => _inProgress.contains(task.title);

  static bool isOverdue(DemoTask task) => !task.done && task.due.startsWith('venció');

  static TaskDetails of(DemoTask task) => _details[task.title] ?? const TaskDetails();

  static const _details = <String, TaskDetails>{
    'Prototipo flujo principal': TaskDetails(
      dueLabel: 'Mié 23/09 · 11:59 p. m.',
      timeLeft: 'Faltan 2 días',
      channel: 'INTU',
      gradePart: 'Proyecto · 15 %',
      reminder: '1 día antes',
      blocks: [
        TaskBlock(title: 'Avanzar en Prototipo', when: 'Dom 20 · 2:00 – 4:00 p. m.', done: true),
        TaskBlock(title: 'Avanzar en Prototipo', when: 'Mar 22 · 10:00 a. m. – 12:00 p. m.'),
      ],
      completedMessage: 'Dos días antes de la fecha límite.',
      subjectProgressLabel: '8 de 10 actividades',
      subjectProgress: 0.8,
      removedBlockNote: 'Quitamos de tu calendario el bloque que te quedaba para esta tarea (mar 22, 10:00 a. m.).',
    ),
    'Parcial 2': TaskDetails(
      dueLabel: 'Jue 24/09 · 2:00 p. m.',
      timeLeft: 'Faltan 3 días',
      place: 'Salón 302',
      gradePart: 'Parciales · 10 %',
      reminder: '1 día antes',
      blocks: [
        TaskBlock(title: 'Estudiar para Parcial 2', when: 'Mar 22 · 3:00 – 5:00 p. m.'),
        TaskBlock(title: 'Estudiar para Parcial 2', when: 'Mié 23 · 3:00 – 5:00 p. m.'),
      ],
    ),
    'Quiz 3: widgets': TaskDetails(
      dueLabel: 'Ayer · 11:59 p. m.',
      timeLeft: 'Vencida',
      overdueMessage: 'Venció ayer a las 11:59 p. m. Cuéntanos para mantener tu lista al día.',
    ),
  };
}
