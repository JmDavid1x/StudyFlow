import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';

/// Tipo de actividad (Figma 14: Tarea, Examen, Proyecto).
enum TaskKind {
  task('Tarea'),
  exam('Examen'),
  project('Proyecto');

  const TaskKind(this.label);
  final String label;
}

/// Prioridad de la actividad.
enum TaskPriority {
  low('Baja'),
  medium('Media'),
  high('Alta');

  const TaskPriority(this.label);
  final String label;
}

/// Dónde se entrega la actividad (Figma 14: "¿Dónde se entrega?").
enum DeliveryChannel {
  intu('INTU', 'Plataforma de la U', Icons.school_outlined),
  email('Correo', 'Por e-mail al profe', Icons.mail_outline),
  inClass('En clase', 'En persona', Icons.groups_outlined),
  whatsapp('WhatsApp', 'Al grupo o al profe', Icons.chat_bubble_outline);

  const DeliveryChannel(this.label, this.subtitle, this.icon);
  final String label;
  final String subtitle;
  final IconData icon;
}

/// Parte de la nota de la materia a la que suma la actividad
/// (Figma 14: "Parte de la nota").
class GradePart {
  const GradePart(this.label, this.weight);

  final String label;

  /// Porcentaje que vale esta parte en la nota final.
  final int weight;
}

/// Partes de la nota del prototipo. En el Sprint 2 salen de cada materia.
const demoGradeParts = <GradePart>[
  GradePart('Talleres', 30),
  GradePart('Proyecto', 40),
  GradePart('Parciales', 30),
];

/// Lo que el usuario llena en el formulario de tarea (Figma 14 y 19).
/// Se usa para cargar el formulario al editar y para mostrar el resumen
/// en Tarea guardada (Figma 15).
class TaskFormData {
  const TaskFormData({
    this.title = '',
    this.subject,
    this.kind = TaskKind.task,
    this.date,
    this.time,
    this.gradePart,
    this.gradeValue = 15,
    this.priority = TaskPriority.medium,
    this.channel,
    this.place = '',
    this.reminder = true,
    this.notes = '',
  });

  final String title;
  final DemoSubject? subject;
  final TaskKind kind;
  final DateTime? date;
  final TimeOfDay? time;
  final GradePart? gradePart;

  /// Porcentaje de la nota que vale esta actividad.
  final int gradeValue;
  final TaskPriority priority;

  /// Canal de entrega. Solo aplica si no es examen.
  final DeliveryChannel? channel;

  /// Lugar del examen. Solo aplica si es examen.
  final String place;
  final bool reminder;
  final String notes;

  /// Carga en el formulario una tarea de [DemoData] (por ejemplo, la que
  /// llega desde Detalle de tarea). DemoTask no trae fecha exacta, así que
  /// la fecha queda por elegir.
  factory TaskFormData.fromDemoTask(DemoTask task) {
    return TaskFormData(
      title: task.title,
      subject: DemoData.subjects.where((s) => s.name == task.subject).firstOrNull,
      kind: task.isExam ? TaskKind.exam : TaskKind.task,
      priority: TaskPriority.values.firstWhere(
        (p) => p.label.toLowerCase() == task.priority,
        orElse: () => TaskPriority.medium,
      ),
    );
  }
}

/// Tarea del prototipo (Figma 15 y 19), para cuando una pantalla se abre
/// sin argumentos, por ejemplo desde el menú de desarrollo.
final prototypeTask = TaskFormData(
  title: 'Prototipo flujo principal',
  subject: DemoData.subjects.first,
  kind: TaskKind.project,
  date: DateTime(2026, 9, 23),
  time: const TimeOfDay(hour: 23, minute: 59),
  gradePart: demoGradeParts[1],
  priority: TaskPriority.high,
  channel: DeliveryChannel.intu,
  notes: 'Solo el flujo principal. Enlazar las pantallas en Figma.',
);
