import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';

/// Rutas de Perfil (Persona 5).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> profileRoutes = {
  AppRoutes.notificationSettings: (_) => const PlaceholderScreen(figma: '26', title: 'Ajustes de notificaciones', owner: Team.p5),
};
