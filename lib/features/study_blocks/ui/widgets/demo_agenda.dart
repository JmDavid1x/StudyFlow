import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';

/// Qué es cada cosa de la agenda (Figma 20).
enum AgendaKind { classSession, studyBlock, delivery, exam }

/// Una cosa de la agenda de un día: clase, bloque de estudio, entrega o
/// examen. Lo usan el Calendario (Figma 20) y el Bloque de estudio (27).
class AgendaItem {
  const AgendaItem({
    required this.kind,
    required this.subject,
    required this.day,
    required this.start,
    this.end,
    this.task,
    this.detail = '',
    this.byAssistant = false,
    this.reminderMinutes = 0,
    this.done = false,
  });

  final AgendaKind kind;
  final DemoSubject subject;

  /// Día del calendario, sin hora.
  final DateTime day;
  final TimeOfDay start;
  final TimeOfDay? end;

  /// Tarea de DemoData: la que se entrega o la que prepara el bloque.
  /// En una clase va vacía.
  final DemoTask? task;

  /// Profesor de la clase, lugar del examen o canal de la entrega.
  final String detail;

  /// Si el bloque lo creó el asistente o el usuario.
  final bool byAssistant;

  /// Minutos antes de empezar en que se avisa. 0 es sin aviso.
  final int reminderMinutes;
  final bool done;

  /// "Avanzar en Taller 3", "Estudiar para Parcial 2", o el nombre de la
  /// tarea o la materia.
  String get title => switch (kind) {
        AgendaKind.classSession => subject.name,
        AgendaKind.studyBlock => task!.isExam ? 'Estudiar para ${task!.title}' : 'Avanzar en ${task!.title}',
        _ => task!.title,
      };

  /// Las clases no se completan; lo demás queda pendiente hasta hacerlo.
  bool get isPending => kind != AgendaKind.classSession && !done;

  /// Minutos entre el inicio y el fin. 0 si no tiene fin (entregas).
  int get durationMinutes {
    final finish = end;
    if (finish == null) return 0;
    return (finish.hour * 60 + finish.minute) - (start.hour * 60 + start.minute);
  }
}

DemoSubject _subjectNamed(String name) => DemoData.subjects.firstWhere((s) => s.name == name);

DemoTask _taskNamed(String title) => DemoData.tasks.firstWhere((t) => t.title == title);

AgendaItem _class(String subject, DateTime day, TimeOfDay start, TimeOfDay end) {
  final s = _subjectNamed(subject);
  return AgendaItem(
    kind: AgendaKind.classSession,
    subject: s,
    day: day,
    start: start,
    end: end,
    detail: s.professor,
  );
}

AgendaItem _block(String task, DateTime day, TimeOfDay start, TimeOfDay end, {bool byAssistant = true}) {
  final t = _taskNamed(task);
  return AgendaItem(
    kind: AgendaKind.studyBlock,
    subject: _subjectNamed(t.subject),
    task: t,
    day: day,
    start: start,
    end: end,
    byAssistant: byAssistant,
    reminderMinutes: 15,
  );
}

AgendaItem _due(String task, DateTime day, TimeOfDay time, String detail) {
  final t = _taskNamed(task);
  return AgendaItem(
    kind: t.isExam ? AgendaKind.exam : AgendaKind.delivery,
    subject: _subjectNamed(t.subject),
    task: t,
    day: day,
    start: time,
    detail: detail,
  );
}

/// Agenda de la semana del prototipo, lunes 21 a domingo 27 de septiembre
/// de 2026, armada con las materias y tareas de DemoData. Las clases siguen
/// el horario de cada materia. En el Sprint 2 sale de Supabase.
abstract final class DemoAgenda {
  /// "Hoy" en el prototipo: lunes 21 de septiembre de 2026.
  static final today = DateTime(2026, 9, 21);

  static final _mon = DateTime(2026, 9, 21);
  static final _tue = DateTime(2026, 9, 22);
  static final _wed = DateTime(2026, 9, 23);
  static final _thu = DateTime(2026, 9, 24);
  static final _fri = DateTime(2026, 9, 25);

  static TimeOfDay _at(int hour, [int minute = 0]) => TimeOfDay(hour: hour, minute: minute);

  static final items = <AgendaItem>[
    // Lunes 21
    _class('Cálculo Integral', _mon, _at(9), _at(11)),
    _block('Taller 3: consultas SQL', _mon, _at(13), _at(15)),
    _block('Lectura capítulo 4', _mon, _at(16), _at(17)),
    _due('Lectura capítulo 4', _mon, _at(18), 'en clase'),
    _due('Taller 3: consultas SQL', _mon, _at(23, 59), 'por INTU'),
    // Martes 22
    _class('Aplicaciones Móviles', _tue, _at(7), _at(9)),
    _block('Prototipo flujo principal', _tue, _at(10), _at(12)),
    _block('Parcial 2', _tue, _at(15), _at(17)),
    // Miércoles 23
    _class('Cálculo Integral', _wed, _at(9), _at(11)),
    _block('Parcial 2', _wed, _at(15), _at(17), byAssistant: false),
    _due('Prototipo flujo principal', _wed, _at(23, 59), 'por INTU'),
    // Jueves 24
    _class('Aplicaciones Móviles', _thu, _at(7), _at(9)),
    _due('Parcial 2', _thu, _at(14), 'Salón 302'),
    // Viernes 25
    _class('Bases de Datos', _fri, _at(14), _at(16)),
  ];

  /// Lo que hay en [day], ordenado por hora.
  static List<AgendaItem> forDay(DateTime day) {
    final list = items.where((item) => DateUtils.isSameDay(item.day, day)).toList()
      ..sort((a, b) => (a.start.hour * 60 + a.start.minute).compareTo(b.start.hour * 60 + b.start.minute));
    return list;
  }

  /// Primer bloque de la semana, para abrir el detalle sin argumentos.
  static AgendaItem get firstBlock => items.firstWhere((item) => item.kind == AgendaKind.studyBlock);

  /// Cuántos bloques hay en la semana para preparar [task].
  static int blocksFor(DemoTask task) =>
      items.where((item) => item.kind == AgendaKind.studyBlock && item.task == task).length;
}

/// "30 min", "1 h", "1 h 30 min".
String formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return '$rest min';
  if (rest == 0) return '$hours h';
  return '$hours h $rest min';
}

/// "1:00 – 3:00 p. m." o "10:00 a. m. – 12:00 p. m.": si las dos horas son
/// del mismo período, el "a. m." o "p. m." se escribe una sola vez.
String formatTimeRange(TimeOfDay start, TimeOfDay? end) {
  final startText = sfFormatTime(start);
  if (end == null) return startText;
  final endText = sfFormatTime(end);
  if (start.period == end.period) {
    return '${startText.substring(0, startText.indexOf(' '))} – $endText';
  }
  return '$startText – $endText';
}
