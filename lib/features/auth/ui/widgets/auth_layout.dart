import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Estructura común de las pantallas de acceso: botón atrás opcional,
/// contenido con scroll y las acciones fijas abajo, que suben con el teclado.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.children,
    required this.actions,
    this.showBack = false,
  });

  final List<Widget> children;
  final List<Widget> actions;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (showBack)
              Padding(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SfIconButton(
                    icon: Icons.chevron_left,
                    tooltip: 'Atrás',
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.md, SfSpacing.screen, SfSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Título y subtítulo de una pantalla de acceso.
class AuthHeading extends StatelessWidget {
  const AuthHeading({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: SfTypography.display),
        const SizedBox(height: SfSpacing.xs),
        Text(subtitle, style: SfTypography.body.copyWith(color: SfColors.textSecondary)),
      ],
    );
  }
}

/// Mensaje de error o de ayuda debajo de un campo.
class AuthFieldNote extends StatelessWidget {
  const AuthFieldNote(this.text, {super.key, this.isError = false});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SfSpacing.xs - 2, left: SfSpacing.xxs),
      child: Text(
        text,
        style: SfTypography.caption.copyWith(color: isError ? SfColors.danger : SfColors.textSecondary),
      ),
    );
  }
}
