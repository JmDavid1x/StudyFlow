import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';
import 'package:studyflow/features/auth/ui/screens/onboarding_screen.dart';
import 'package:studyflow/features/auth/ui/screens/splash_screen.dart';

/// Rutas de Acceso (Jose David).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> authRoutes = {
  AppRoutes.splash: (_) => const SplashScreen(),
  AppRoutes.onboarding: (_) => const OnboardingScreen(),
  AppRoutes.register: (_) => const PlaceholderScreen(figma: '04', title: 'Registro', owner: Team.p1),
  AppRoutes.login: (_) => const PlaceholderScreen(figma: '05', title: 'Iniciar sesión', owner: Team.p1),
  AppRoutes.forgotPassword: (_) => const PlaceholderScreen(figma: '06', title: 'Recuperar contraseña', owner: Team.p1),
  AppRoutes.emailSent: (_) => const PlaceholderScreen(figma: '07', title: 'Correo enviado', owner: Team.p1),
};
