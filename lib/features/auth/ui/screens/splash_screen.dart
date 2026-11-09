import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/auth/ui/bloc/auth_bloc.dart';
import 'package:studyflow/features/auth/ui/widgets/brand_mark.dart';

/// Splash (Figma 01). Muestra la marca un momento mientras el AuthBloc
/// revisa si había sesión guardada:
/// - con sesión y configuración terminada → Inicio;
/// - con sesión pero sin configurar → configuración inicial (Figma 08);
/// - sin sesión → onboarding.
/// Tocar la pantalla salta la espera de la marca.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _wait = Duration(milliseconds: 1600);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_wait, _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _leaving = false;

  Future<void> _goNext() async {
    _timer?.cancel();
    if (_leaving) return;
    _leaving = true;
    final bloc = context.read<AuthBloc>();
    // Si el AuthBloc todavía no sabe si hay sesión, se espera a que lo sepa.
    final state = bloc.state.sesion == Sesion.desconocida
        ? await bloc.stream.firstWhere((s) => s.sesion != Sesion.desconocida)
        : bloc.state;
    if (!mounted) return;

    if (state.sesion != Sesion.activa) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    } else if (state.perfil?.configuracionCompleta == false) {
      Navigator.pushReplacementNamed(context, AppRoutes.setupSubjects);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.main, arguments: AppTabs.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: _goNext,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandMark(size: 96),
                const SizedBox(height: SfSpacing.lg),
                Text('StudyFlow', style: SfTypography.display),
                const SizedBox(height: SfSpacing.xs),
                Text(
                  'Tu semestre en un solo lugar.',
                  style: SfTypography.body.copyWith(color: SfColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
