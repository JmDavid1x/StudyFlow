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
    required this.title,
    required this.subject,
    required this.day,
    required this.start,
    this.end,
    this.detail = '',
    this.byAssistant = false,
    this.done = false,
  });

  final AgendaKind kind;

  /// Nombre del bloque, la entrega o el examen. En una clase va vacío.
  final String title;
  final DemoSubject subject;

  /// Día del calendario, sin hora.
  final DateTime day;
  final TimeOfDay start;
  final TimeOfDay? end;

  /// Salón de la clase o del examen, o canal de la entrega.
  final String detail;

  /// Si el bloque lo creó el asistente o el usuario.
  final bool byAssistant;
  final bool done;

  /// Las clases no se completan; lo demás queda pendiente hasta hacerlo.
  bool get isPending => kind != AgendaKind.classSession && !done;
}

DemoSubject _subject(String name) => DemoData.subjects.firstWhere((s) => s.name == name);

/// Agenda de la semana del prototipo: lunes 21 a domingo 27 de septiembre
/// de 2026. En el Sprint 2 sale de Supabase.
abstract final class DemoAgenda {
  /// "Hoy" en el prototipo: lunes 21 de septiembre de 2026.
  static final today = DateTime(2026, 9, 21);

  static final items = <AgendaItem>[
    // Lunes 21
    AgendaItem(
      kind: AgendaKind.classSession,
      title: '',
      subject: _subject('Bases de Datos'),
      day: DateTime(2026, 9, 21),
      start: const TimeOfDay(hour: 9, minute: 0),
      end: const TimeOfDay(hour: 11, minute: 0),
      detail: 'Lab 3',
    ),
    AgendaItem(
      kind: AgendaKind.studyBlock,
      title: 'Avanzar en Taller 3',
      subject: _subject('Bases de Datos'),
      day: DateTime(2026, 9, 21),
      start: const TimeOfDay(hour: 13, minute: 0),
      end: const TimeOfDay(hour: 15, minute: 0),
      byAssistant: true,
    ),
    AgendaItem(
      kind: AgendaKind.studyBlock,
      title: 'Avanzar en Lectura capítulo 4',
      subject: _subject('Cálculo Integral'),
      day: DateTime(2026, 9, 21),
      start: const TimeOfDay(hour: 16, minute: 0),
      end: const TimeOfDay(hour: 17, minute: 0),
      byAssistant: true,
    ),
    AgendaItem(
      kind: AgendaKind.classSession,
      title: '',
      subject: _subject('Cálculo Integral'),
      day: DateTime(2026, 9, 21),
      start: const TimeOfDay(hour: 18, minute: 0),
      end: const TimeOfDay(hour: 20, minute: 0),
      detail: 'Salón 205D',
    ),
    AgendaItem(
      kind: AgendaKind.delivery,
      title: 'Lectura capítulo 4',
      subject: _subject('Cálculo Integral'),
      day: DateTime(2026, 9, 21),
      start: const TimeOfDay(hour: 18, minute: 0),
      detail: 'en clase',
    ),
    AgendaItem(
      kind: AgendaKind.delivery,
      title: 'Taller 3: consultas SQL',
      subject: _subject('Bases de Datos'),
      day: DateTime(2026, 9, 21),
      start: const TimeOfDay(hour: 23, minute: 59),
      detail: 'por INTU',
    ),
    // Martes 22
    AgendaItem(
      kind: AgendaKind.classSession,
      title: '',
      subject: _subject('Aplicaciones Móviles'),
      day: DateTime(2026, 9, 22),
      start: const TimeOfDay(hour: 7, minute: 0),
      end: const TimeOfDay(hour: 9, minute: 0),
      detail: 'Salón 401C',
    ),
    AgendaItem(
      kind: AgendaKind.studyBlock,
      title: 'Avanzar en Prototipo',
      subject: _subject('Aplicaciones Móviles'),
      day: DateTime(2026, 9, 22),
      start: const TimeOfDay(hour: 10, minute: 0),
      end: const TimeOfDay(hour: 12, minute: 0),
      byAssistant: true,
    ),
    AgendaItem(
      kind: AgendaKind.studyBlock,
      title: 'Estudiar para Parcial 2',
      subject: _subject('Cálculo Integral'),
      day: DateTime(2026, 9, 22),
      start: const TimeOfDay(hour: 15, minute: 0),
      end: const TimeOfDay(hour: 17, minute: 0),
      byAssistant: true,
    ),
    // Miércoles 23
    AgendaItem(
      kind: AgendaKind.studyBlock,
      title: 'Estudiar para Parcial 2',
      subject: _subject('Cálculo Integral'),
      day: DateTime(2026, 9, 23),
      start: const TimeOfDay(hour: 15, minute: 0),
      end: const TimeOfDay(hour: 17, minute: 0),
      byAssistant: true,
    ),
    AgendaItem(
      kind: AgendaKind.classSession,
      title: '',
      subject: _subject('Cálculo Integral'),
      day: DateTime(2026, 9, 23),
      start: const TimeOfDay(hour: 18, minute: 0),
      end: const TimeOfDay(hour: 20, minute: 0),
      detail: 'Salón 205D',
    ),
    AgendaItem(
      kind: AgendaKind.delivery,
      title: 'Prototipo flujo principal',
      subject: _subject('Aplicaciones Móviles'),
      day: DateTime(2026, 9, 23),
      start: const TimeOfDay(hour: 23, minute: 59),
      detail: 'por INTU',
    ),
    // Jueves 24
    AgendaItem(
      kind: AgendaKind.classSession,
      title: '',
      subject: _subject('Aplicaciones Móviles'),
      day: DateTime(2026, 9, 24),
      start: const TimeOfDay(hour: 7, minute: 0),
      end: const TimeOfDay(hour: 9, minute: 0),
      detail: 'Salón 401C',
    ),
    AgendaItem(
      kind: AgendaKind.classSession,
      title: '',
      subject: _subject('Bases de Datos'),
      day: DateTime(2026, 9, 24),
      start: const TimeOfDay(hour: 9, minute: 0),
      end: const TimeOfDay(hour: 11, minute: 0),
      detail: 'Lab 3',
    ),
    AgendaItem(
      kind: AgendaKind.exam,
      title: 'Parcial 2',
      subject: _subject('Cálculo Integral'),
      day: DateTime(2026, 9, 24),
      start: const TimeOfDay(hour: 14, minute: 0),
      detail: 'Salón 302',
    ),
    // Viernes 25
    AgendaItem(
      kind: AgendaKind.studyBlock,
      title: 'Avanzar en Taller 4',
      subject: _subject('Aplicaciones Móviles'),
      day: DateTime(2026, 9, 25),
      start: const TimeOfDay(hour: 15, minute: 0),
      end: const TimeOfDay(hour: 16, minute: 30),
    ),
  ];

  /// Lo que hay en [day], ordenado por hora.
  static List<AgendaItem> forDay(DateTime day) {
    final list = items.where((item) => DateUtils.isSameDay(item.day, day)).toList()
      ..sort((a, b) => (a.start.hour * 60 + a.start.minute).compareTo(b.start.hour * 60 + b.start.minute));
    return list;
  }
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
