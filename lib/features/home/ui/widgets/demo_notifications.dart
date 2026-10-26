import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';

/// Un aviso de Notificaciones (Figma 13).
class DemoNotification {
  const DemoNotification({
    required this.id,
    required this.day,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.time,
    this.filled = false,
    this.unread = false,
    this.route,
    this.taskTitle,
  });

  final String id;

  /// "Hoy" o "Ayer": el grupo donde se muestra.
  final String day;
  final IconData icon;
  final Color color;

  /// Ícono sobre fondo de color sólido; si no, sobre el color suave.
  final bool filled;
  final String title;
  final String message;

  /// "9:00 a. m."
  final String time;
  final bool unread;

  /// A dónde lleva al tocarlo. Null si solo se marca como leído.
  final String? route;

  /// Tarea de DemoData que se pasa como argumento a [route].
  final String? taskTitle;

  DemoTask? get task => taskTitle == null ? null : DemoData.tasks.firstWhere((task) => task.title == taskTitle);
}

/// Los avisos del prototipo, tal cual Figma 13. En el Sprint 2 llegan de
/// Supabase.
abstract final class DemoNotifications {
  static const days = ['Hoy', 'Ayer'];

  static const all = <DemoNotification>[
    DemoNotification(
      id: 'vence-prototipo',
      day: 'Hoy',
      icon: Icons.alarm_rounded,
      color: SfColors.primaryLight,
      title: 'Mañana vence: Prototipo flujo principal',
      message: 'Se entrega por INTU · 11:59 p. m.',
      time: '9:00 a. m.',
      unread: true,
      route: AppRoutes.taskDetail,
      taskTitle: 'Prototipo flujo principal',
    ),
    DemoNotification(
      id: 'plan-de-hoy',
      day: 'Hoy',
      icon: Icons.smart_toy_outlined,
      color: SfColors.primary,
      filled: true,
      title: 'Tu plan de hoy está listo',
      message: 'Empieza por la Lectura capítulo 4',
      time: '7:00 a. m.',
      unread: true,
      route: AppRoutes.assistant,
    ),
    DemoNotification(
      id: 'completaste-taller-2',
      day: 'Ayer',
      icon: Icons.check_rounded,
      color: SfColors.success,
      filled: true,
      title: 'Completaste Taller 2: normalización',
      message: 'Bases de Datos · a tiempo',
      time: '5:40 p. m.',
      route: AppRoutes.taskDetail,
      taskTitle: 'Taller 2: normalización',
    ),
    DemoNotification(
      id: 'vence-quiz-3',
      day: 'Ayer',
      icon: Icons.alarm_rounded,
      color: SfColors.warning,
      title: 'Hoy vence: Quiz 3 de Cálculo',
      message: 'Se entrega en clase · 9:00 a. m.',
      time: '7:00 a. m.',
    ),
  ];
}
