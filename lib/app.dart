import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_router.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/auth/data/auth_repository_impl.dart';
import 'package:studyflow/features/auth/ui/bloc/auth_bloc.dart';

/// Widget raíz: tema, idioma, rutas y el AuthBloc que comparte toda la app.
class StudyFlowApp extends StatefulWidget {
  const StudyFlowApp({super.key});

  @override
  State<StudyFlowApp> createState() => _StudyFlowAppState();
}

class _StudyFlowAppState extends State<StudyFlowApp> {
  /// Permite navegar cuando cambia la sesión, sin depender de una pantalla.
  final _navigatorKey = GlobalKey<NavigatorState>();

  void _onSessionChanged(BuildContext context, AuthState state) {
    final navigator = _navigatorKey.currentState;
    if (state.sesion == Sesion.recuperacion) {
      // Abrió el enlace del correo: pide la contraseña nueva.
      navigator?.pushNamedAndRemoveUntil(AppRoutes.newPassword, (_) => false);
    } else {
      // Cerró sesión (desde Perfil) o la sesión venció: vuelve al login sin historial.
      navigator?.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(AuthRepositoryImpl(supabase))..add(const AuthIniciado()),
      child: MaterialApp(
        title: 'StudyFlow',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        theme: SfTheme.dark,
        themeMode: ThemeMode.dark,
        locale: const Locale('es'),
        supportedLocales: const [Locale('es'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        initialRoute: AppRoutes.splash,
        routes: AppRouter.routes,
        onUnknownRoute: AppRouter.unknown,
        builder: (context, child) => BlocListener<AuthBloc, AuthState>(
          listenWhen: (before, now) =>
              (now.sesion == Sesion.recuperacion && before.sesion != Sesion.recuperacion) ||
              (now.sesion == Sesion.cerrada && before.sesion != Sesion.cerrada && before.sesion != Sesion.desconocida),
          listener: _onSessionChanged,
          child: child!,
        ),
      ),
    );
  }
}
