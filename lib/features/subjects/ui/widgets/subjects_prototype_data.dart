import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Datos de ejemplo de las pantallas de materias, tomados del prototipo de
/// Figma (pantallas 08, 21, 22 y 23).
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
    required this.scheduleStart,
    required this.credits,
    required this.grade,
    required this.goal,
  });

  final String name;
  final String professor;
  final Color color;

  /// "Mar y jue · 7:00 – 9:00 a. m."
  final String schedule;

  /// "Mar y jue, 7:00 a. m."
  final String scheduleStart;
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
    scheduleStart: 'Mar y jue, 7:00 a. m.',
    credits: 3,
    grade: 4.1,
    goal: 4.4,
  ),
  PrototypeSubject(
    name: 'Cálculo Integral',
    professor: 'Prof. Laura Méndez',
    color: SfColors.warning,
    schedule: 'Lun y mié · 6:00 – 8:00 p. m.',
    scheduleStart: 'Lun y mié, 6:00 p. m.',
    credits: 4,
    grade: 3.8,
    goal: 4.0,
  ),
  PrototypeSubject(
    name: 'Bases de Datos',
    professor: 'Prof. Camilo Torres',
    color: SfColors.info,
    schedule: 'Lun y jue · 9:00 – 11:00 a. m.',
    scheduleStart: 'Lun y jue, 9:00 a. m.',
    credits: 3,
    grade: 4.3,
    goal: 4.5,
  ),
];

/// Materia que llega como argumento de la ruta. Si no llega ninguna, se usa
/// la primera (así la pantalla también se abre desde el menú de desarrollo).
PrototypeSubject subjectFromArguments(Object? arguments) =>
    arguments is PrototypeSubject ? arguments : prototypeSubjects.first;

/// Componente de la nota: "Talleres · 30 %".
class PrototypeComponent {
  const PrototypeComponent({
    required this.name,
    required this.percent,
    required this.result,
  });

  final String name;
  final int percent;

  /// "4.3", "Sin nota" o "3.8 · 2 de 3".
  final String result;
}

/// Componentes de Aplicaciones Móviles (Figma 22).
const prototypeComponents = <PrototypeComponent>[
  PrototypeComponent(name: 'Talleres', percent: 30, result: '4.3'),
  PrototypeComponent(name: 'Proyecto', percent: 40, result: 'Sin nota'),
  PrototypeComponent(name: 'Parciales', percent: 30, result: '3.8 · 2 de 3'),
];

/// Actividad de una materia (Figma 22 y 23).
class PrototypeActivity {
  const PrototypeActivity({
    required this.title,
    required this.component,
    required this.detail,
    required this.listDetail,
    this.done = false,
    this.recent = false,
  });

  final String title;

  /// Nombre del componente al que pertenece: "Proyecto".
  final String component;

  /// Texto en la pantalla 23: "Proyecto · entregado lun 21/09".
  final String detail;

  /// Texto en la pantalla 22: "Entregada por INTU · lun 21/09".
  final String listDetail;
  final bool done;

  /// Muestra la insignia "Recién completada".
  final bool recent;
}

const prototypeActivities = <PrototypeActivity>[
  PrototypeActivity(
    title: 'Prototipo flujo principal',
    component: 'Proyecto',
    detail: 'Proyecto · entregado lun 21/09',
    listDetail: 'Entregada por INTU · lun 21/09',
    done: true,
    recent: true,
  ),
  PrototypeActivity(
    title: 'Taller 4: widgets',
    component: 'Talleres',
    detail: 'Talleres · entregado vie 18/09',
    listDetail: 'Talleres · entregado vie 18/09',
    done: true,
  ),
  PrototypeActivity(
    title: 'Parcial 3',
    component: 'Parciales',
    detail: 'Parciales · lun 05/10',
    listDetail: 'Parciales · lun 05/10',
  ),
];
