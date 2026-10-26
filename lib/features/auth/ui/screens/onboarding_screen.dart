import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/auth/ui/widgets/onboarding_parts.dart';

/// Onboarding (Figma 02 y 03): dos páginas que se deslizan. "Siguiente"
/// avanza; en la última, "Crear cuenta" lleva al registro. "Saltar" va
/// directo al registro.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 2;

  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == _pageCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      Navigator.pushReplacementNamed(context, AppRoutes.register);
      return;
    }
    _controller.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.xs, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SfButton(
                  label: 'Saltar',
                  variant: SfButtonVariant.ghost,
                  expand: false,
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.register),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: const [
                  OnboardingPage(
                    illustration: SourcesIllustration(),
                    title: 'Todas tus entregas en un solo lugar',
                    message: 'Anota lo que llega por correo, WhatsApp, INTU o en clase y míralo junto en tu Inicio.',
                  ),
                  OnboardingPage(
                    illustration: RemindersIllustration(),
                    title: 'Sabe qué hacer primero',
                    message: 'Te avisamos antes de cada entrega y el asistente te sugiere por dónde empezar, '
                        'sin chocar con tus clases.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.md, SfSpacing.screen, SfSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageDots(count: _pageCount, current: _page),
                  const SizedBox(height: SfSpacing.lg),
                  SfButton(label: _isLast ? 'Crear cuenta' : 'Siguiente', onPressed: _next),
                  if (_isLast) ...[
                    const SizedBox(height: SfSpacing.xxs),
                    SfButton(
                      label: 'Ya tengo cuenta',
                      variant: SfButtonVariant.ghost,
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
