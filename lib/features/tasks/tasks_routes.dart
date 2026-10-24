import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';

/// Rutas de Inicio y tareas (Persona 3).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> tasksRoutes = {
  AppRoutes.notifications: (_) => const PlaceholderScreen(figma: '13', title: 'Notificaciones', owner: Team.p3),
  AppRoutes.taskDetail: (_) => const PlaceholderScreen(figma: '18', title: 'Detalle de tarea', owner: Team.p3),
  AppRoutes.examDetail: (_) => const PlaceholderScreen(figma: '29', title: 'Detalle de examen', owner: Team.p3),
};
