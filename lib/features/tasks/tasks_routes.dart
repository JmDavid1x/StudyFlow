import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/home/ui/screens/notifications_screen.dart';
import 'package:studyflow/features/tasks/ui/screens/exam_detail_screen.dart';
import 'package:studyflow/features/tasks/ui/screens/task_detail_screen.dart';

/// Rutas de Inicio y tareas (Perez).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> tasksRoutes = {
  AppRoutes.notifications: (_) => const NotificationsScreen(),
  AppRoutes.taskDetail: (_) => const TaskDetailScreen(),
  AppRoutes.examDetail: (_) => const ExamDetailScreen(),
};
