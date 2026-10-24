import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';

/// Rutas de Formularios de tarea (Persona 4).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> taskFormRoutes = {
  AppRoutes.newTask: (_) => const PlaceholderScreen(figma: '14', title: 'Nueva tarea', owner: Team.p4),
  AppRoutes.taskSaved: (_) => const PlaceholderScreen(figma: '15', title: 'Tarea guardada', owner: Team.p4),
  AppRoutes.editTask: (_) => const PlaceholderScreen(figma: '19', title: 'Editar tarea', owner: Team.p4),
};
