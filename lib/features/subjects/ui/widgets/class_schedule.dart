import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Un horario de clase: día, hora de inicio, hora de fin y salón opcional.
class ClassSchedule {
  const ClassSchedule({
    required this.day,
    required this.start,
    required this.end,
    this.room = '',
  });

  /// "Martes"
  final String day;
  final TimeOfDay start;
  final TimeOfDay end;

  /// "Salón 401C", o vacío si no se indicó.
  final String room;

  /// "7:00 – 9:00 a. m." (si cambia de mañana a tarde, muestra las dos).
  String get timeRange {
    final startLabel = sfFormatTime(start);
    final endLabel = sfFormatTime(end);
    if (start.period == end.period) {
      return '${startLabel.substring(0, startLabel.indexOf(' '))} – $endLabel';
    }
    return '$startLabel – $endLabel';
  }

  /// "7:00 – 9:00 a. m. · Salón 401C"
  String get summary => room.isEmpty ? timeRange : '$timeRange · $room';
}
