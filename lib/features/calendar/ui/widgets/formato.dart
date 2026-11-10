import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// "6:00 p. m." a partir de una fecha con hora.
String horaDe(DateTime t) => sfFormatTime(TimeOfDay.fromDateTime(t));

/// "1:00 – 3:00 p. m." o "10:00 a. m. – 12:00 p. m.": si las dos horas son
/// del mismo período, el "a. m." o "p. m." se escribe una sola vez.
String rangoHoras(DateTime inicio, DateTime fin) {
  final desde = horaDe(inicio);
  final hasta = horaDe(fin);
  if ((inicio.hour < 12) == (fin.hour < 12)) {
    return '${desde.substring(0, desde.indexOf(' '))} – $hasta';
  }
  return '$desde – $hasta';
}

/// "30 min", "1 h", "1 h 30 min".
String duracionTexto(Duration duracion) {
  final horas = duracion.inMinutes ~/ 60;
  final minutos = duracion.inMinutes % 60;
  if (horas == 0) return '$minutos min';
  if (minutos == 0) return '$horas h';
  return '$horas h $minutos min';
}
