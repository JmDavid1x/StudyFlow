import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subjects/ui/widgets/class_schedule.dart';

/// Color de Flutter → '#A78BFA' (como se guarda en la base).
String colorAHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

const _diasSemana = {
  'lunes': 1,
  'martes': 2,
  'miércoles': 3,
  'jueves': 4,
  'viernes': 5,
  'sábado': 6,
  'domingo': 7,
};

/// 'Martes' → 2 (1 = lunes … 7 = domingo).
int diaSemanaDe(String dia) => _diasSemana[dia.toLowerCase()] ?? 1;

/// Horario de la hoja S9 → fila de `horarios_clase` (sin id: lo pone la base).
HorarioClase horarioDesdeClase(ClassSchedule clase) => HorarioClase(
  id: '',
  materiaId: '',
  diaSemana: diaSemanaDe(clase.day),
  horaInicio: Hora(clase.start.hour, clase.start.minute),
  horaFin: Hora(clase.end.hour, clase.end.minute),
  salon: clase.room.isEmpty ? null : clase.room,
);
