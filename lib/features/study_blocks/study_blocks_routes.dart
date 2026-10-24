import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';

/// Rutas de Bloques de estudio (Camilo).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> studyBlocksRoutes = {
  AppRoutes.studyBlock: (_) => const PlaceholderScreen(figma: '27', title: 'Bloque de estudio', owner: Team.p4),
  AppRoutes.newStudyBlock: (_) => const PlaceholderScreen(figma: '28', title: 'Nuevo bloque', owner: Team.p4),
};
