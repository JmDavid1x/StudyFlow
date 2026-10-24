import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';
import 'package:studyflow/features/task_form/ui/screens/new_task_screen.dart';

/// Rutas de Formularios de tarea (Camilo).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> taskFormRoutes = {
  AppRoutes.newTask: (_) => const NewTaskScreen(),
  AppRoutes.taskSaved: (_) => const PlaceholderScreen(figma: '15', title: 'Tarea guardada', owner: Team.p4),
  AppRoutes.editTask: (_) => const PlaceholderScreen(figma: '19', title: 'Editar tarea', owner: Team.p4),
};
