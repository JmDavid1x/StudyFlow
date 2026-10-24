import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';

/// Rutas de StudyFlow Plus (Persona 5).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> subscriptionRoutes = {
  AppRoutes.plus: (_) => const PlaceholderScreen(figma: '30', title: 'StudyFlow Plus', owner: Team.p5),
  AppRoutes.payment: (_) => const PlaceholderScreen(figma: '32', title: 'Pago', owner: Team.p5),
};
