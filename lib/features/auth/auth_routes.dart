import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/auth/ui/screens/email_sent_screen.dart';
import 'package:studyflow/features/auth/ui/screens/forgot_password_screen.dart';
import 'package:studyflow/features/auth/ui/screens/login_screen.dart';
import 'package:studyflow/features/auth/ui/screens/new_password_screen.dart';
import 'package:studyflow/features/auth/ui/screens/onboarding_screen.dart';
import 'package:studyflow/features/auth/ui/screens/register_screen.dart';
import 'package:studyflow/features/auth/ui/screens/splash_screen.dart';

/// Rutas de Acceso (Jose David): splash, onboarding, registro, inicio de
/// sesión, recuperar contraseña y crear la contraseña nueva.
final Map<String, WidgetBuilder> authRoutes = {
  AppRoutes.splash: (_) => const SplashScreen(),
  AppRoutes.onboarding: (_) => const OnboardingScreen(),
  AppRoutes.register: (_) => const RegisterScreen(),
  AppRoutes.login: (_) => const LoginScreen(),
  AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
  AppRoutes.emailSent: (_) => const EmailSentScreen(),
  AppRoutes.newPassword: (_) => const NewPasswordScreen(),
};
