import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/task_form/ui/screens/edit_task_screen.dart';
import 'package:studyflow/features/task_form/ui/screens/new_task_screen.dart';
import 'package:studyflow/features/task_form/ui/screens/task_saved_screen.dart';

/// Rutas de Formularios de tarea (Camilo).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> taskFormRoutes = {
  AppRoutes.newTask: (_) => const NewTaskScreen(),
  AppRoutes.taskSaved: (_) => const TaskSavedScreen(),
  AppRoutes.editTask: (_) => const EditTaskScreen(),
};
