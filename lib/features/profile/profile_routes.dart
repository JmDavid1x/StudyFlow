import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/profile/ui/screens/notification_settings_screen.dart';

/// Rutas de Perfil (Santiago).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> profileRoutes = {
  AppRoutes.notificationSettings: (_) => const NotificationSettingsScreen(),
};
