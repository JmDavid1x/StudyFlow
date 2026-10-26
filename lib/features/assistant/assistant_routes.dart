import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/assistant/ui/screens/assistant_screen.dart';

/// Rutas de Asistente (Santiago).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> assistantRoutes = {
  AppRoutes.assistant: (_) => const AssistantScreen(),
};
