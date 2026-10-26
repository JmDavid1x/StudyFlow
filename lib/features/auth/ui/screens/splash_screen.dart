import 'dart:async';

import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/auth/ui/widgets/brand_mark.dart';

/// Splash (Figma 01). Muestra la marca un momento y pasa al onboarding.
/// Tocar la pantalla salta la espera.
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

  void _goNext() {
    _timer?.cancel();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
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
