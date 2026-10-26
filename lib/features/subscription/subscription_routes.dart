import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/subscription/ui/screens/payment_screen.dart';
import 'package:studyflow/features/subscription/ui/screens/plus_screen.dart';

/// Rutas de StudyFlow Plus (Santiago).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> subscriptionRoutes = {
  AppRoutes.plus: (_) => const PlusScreen(),
  AppRoutes.payment: (_) => const PaymentScreen(),
};
