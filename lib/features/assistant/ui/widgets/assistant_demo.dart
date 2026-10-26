import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/demo_agenda.dart';

/// Quién escribió un mensaje del chat.
enum ChatAuthor { user, assistant }

/// Qué se ve debajo de un mensaje del asistente.
enum ChatAttachment { none, suggestedOrder, offline }

/// Un mensaje del chat del asistente (Figma 24 y 31).
class ChatMessage {
  const ChatMessage({
    required this.author,
    required this.text,
    this.attachment = ChatAttachment.none,
  });

  final ChatAuthor author;
  final String text;
  final ChatAttachment attachment;

  bool get isUser => author == ChatAuthor.user;
}

/// Una actividad del orden sugerido con sus bloques de estudio.
class PlanStep {
  const PlanStep({required this.task, required this.blocks});

  final DemoTask task;
  final List<AgendaItem> blocks;
}

/// Respuestas fijas del asistente para el Sprint 1. No hay IA real: en el
/// Sprint 2 esto se reemplaza por la respuesta del servicio de IA.
abstract final class AssistantDemo {
  static const freeUsed = 3;
  static const freeLimit = 5;

  static const suggestions = <String>[
    '¿Qué hago hoy?',
    'Organiza mi semana',
    '¿Cómo voy en Cálculo?',
  ];

  static const firstMessages = <ChatMessage>[
    ChatMessage(
      author: ChatAuthor.user,
      text: '¿En qué orden hago mis tareas de esta semana?',
    ),
    ChatMessage(
      author: ChatAuthor.assistant,
      text: 'Revisé tus entregas y tu horario. Empieza por lo que vence primero '
          'y deja el parcial para cuando ya tengas lo demás listo.',
      attachment: ChatAttachment.suggestedOrder,
    ),
  ];

  static const offlineMessage = ChatMessage(
    author: ChatAuthor.assistant,
    text: 'No pude responderte en este momento.',
    attachment: ChatAttachment.offline,
  );

  static const retryMessage = ChatMessage(
    author: ChatAuthor.assistant,
    text: 'Listo, ya pude revisar tu semana. Este orden sigue siendo el mejor.',
    attachment: ChatAttachment.suggestedOrder,
  );

  /// Orden sugerido: las tareas pendientes ordenadas por su primer bloque del
  /// asistente en el calendario, para que coincida con la pestaña Calendario.
  static List<PlanStep> get suggestedOrder {
    final tasks = <DemoTask>[];
    for (final block in _assistantBlocks) {
      if (!tasks.contains(block.task)) tasks.add(block.task!);
    }
    return planFor(tasks);
  }

  /// Cada tarea de [tasks], en ese orden, con sus bloques del asistente.
  static List<PlanStep> planFor(List<DemoTask> tasks) => [
        for (final task in tasks)
          PlanStep(
            task: task,
            blocks: _assistantBlocks.where((block) => block.task == task).toList(),
          ),
      ];

  static Iterable<AgendaItem> get _assistantBlocks => DemoAgenda.items
      .where((item) => item.kind == AgendaKind.studyBlock && item.byAssistant);

  /// Orden de respaldo cuando la IA no responde: las pendientes por prioridad
  /// (alta, media, baja). Las de igual prioridad quedan como en DemoData.
  static List<DemoTask> get fallbackOrder {
    const rank = {'alta': 0, 'media': 1, 'baja': 2};
    final pending = DemoData.tasks.where((task) => !task.done).toList();
    return [
      for (final level in rank.keys) ...pending.where((task) => task.priority == level),
    ];
  }
}
