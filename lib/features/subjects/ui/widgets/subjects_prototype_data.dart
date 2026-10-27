import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Datos de ejemplo de las pantallas de materias, tomados del prototipo de
/// Figma (pantallas 08, 21 y 22).
///
/// `DemoData` todavía no trae los créditos y algunos horarios, profesores y
/// metas no coinciden con Figma. Mientras el grupo lo alinea, estas pantallas
/// usan estos datos para verse igual que el prototipo.
/// En el Sprint 2 se reemplazan por datos reales de Supabase.
class PrototypeSubject {
  const PrototypeSubject({
    required this.name,
    required this.professor,
    required this.color,
    required this.schedule,
    required this.credits,
    required this.grade,
    required this.goal,
  });

  final String name;
  final String professor;
  final Color color;

  /// "Mar y jue · 7:00 – 9:00 a. m."
  final String schedule;
  final int credits;
  final double grade;
  final double goal;
}

const prototypeSubjects = <PrototypeSubject>[
  PrototypeSubject(
    name: 'Aplicaciones Móviles',
    professor: 'Prof. Andrés Ruiz',
    color: SfColors.primaryLight,
    schedule: 'Mar y jue · 7:00 – 9:00 a. m.',
    credits: 3,
    grade: 4.1,
    goal: 4.4,
  ),
  PrototypeSubject(
    name: 'Cálculo Integral',
    professor: 'Prof. Laura Méndez',
    color: SfColors.warning,
    schedule: 'Lun y mié · 6:00 – 8:00 p. m.',
    credits: 4,
    grade: 3.8,
    goal: 4.0,
  ),
  PrototypeSubject(
    name: 'Bases de Datos',
    professor: 'Prof. Camilo Torres',
    color: SfColors.info,
    schedule: 'Lun y jue · 9:00 – 11:00 a. m.',
    credits: 3,
    grade: 4.3,
    goal: 4.5,
  ),
];
