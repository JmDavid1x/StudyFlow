import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';

/// Datos de ejemplo para el Sprint 1 (solo interfaz). Son los mismos del
/// prototipo de Figma, para que todas las pantallas cuenten la misma historia.
///
/// En el Sprint 2 esto se reemplaza por datos reales de Supabase y se borra.
class DemoSubject {
  const DemoSubject({
    required this.name,
    required this.professor,
    required this.color,
    required this.schedule,
    this.grade,
    this.goal,
  });

  final String name;
  final String professor;
  final Color color;

  /// "Mar y jue, 7:00 a. m."
  final String schedule;
  final double? grade;
  final double? goal;
}

class DemoTask {
  const DemoTask({
    required this.title,
    required this.subject,
    required this.color,
    required this.due,
    required this.priority,
    this.isExam = false,
    this.done = false,
  });

  final String title;
  final String subject;
  final Color color;

  /// "hoy 11:59 p. m."
  final String due;

  /// alta, media o baja.
  final String priority;
  final bool isExam;
  final bool done;
}

abstract final class DemoData {
  static const studentName = 'Santiago';

  static const subjects = <DemoSubject>[
    DemoSubject(
      name: 'Aplicaciones Móviles',
      professor: 'Prof. Andrés Ruiz',
      color: SfColors.primaryLight,
      schedule: 'Mar y jue, 7:00 a. m.',
      grade: 4.1,
      goal: 4.5,
    ),
    DemoSubject(
      name: 'Cálculo Integral',
      professor: 'Prof. Laura Méndez',
      color: SfColors.warning,
      schedule: 'Lun y mié, 9:00 a. m.',
      grade: 3.8,
      goal: 4.0,
    ),
    DemoSubject(
      name: 'Bases de Datos',
      professor: 'Prof. Carlos Peña',
      color: SfColors.info,
      schedule: 'Vie, 2:00 p. m.',
    ),
  ];

  static const tasks = <DemoTask>[
    DemoTask(
      title: 'Taller 3: consultas SQL',
      subject: 'Bases de Datos',
      color: SfColors.info,
      due: 'hoy 11:59 p. m.',
      priority: 'alta',
    ),
    DemoTask(
      title: 'Lectura capítulo 4',
      subject: 'Cálculo Integral',
      color: SfColors.warning,
      due: 'hoy 6:00 p. m.',
      priority: 'media',
    ),
    DemoTask(
      title: 'Prototipo flujo principal',
      subject: 'Aplicaciones Móviles',
      color: SfColors.primaryLight,
      due: 'mié 23/09',
      priority: 'alta',
    ),
    DemoTask(
      title: 'Parcial 2',
      subject: 'Cálculo Integral',
      color: SfColors.warning,
      due: 'jue 24/09',
      priority: 'alta',
      isExam: true,
    ),
    DemoTask(
      title: 'Taller 2: normalización',
      subject: 'Bases de Datos',
      color: SfColors.info,
      due: 'entregada dom 20/09',
      priority: 'media',
      done: true,
    ),
  ];
}
