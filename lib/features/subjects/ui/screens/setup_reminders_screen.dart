import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/subjects/ui/widgets/reminder_preview_card.dart';

/// Activar recordatorios, paso 2 de la configuración inicial (Figma 10).
///
/// Explica los avisos y deja activarlos. Al terminar, de cualquier forma,
/// lleva al Inicio.
class SetupRemindersScreen extends StatelessWidget {
  const SetupRemindersScreen({super.key});

  void _goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.main,
      (_) => false,
      arguments: AppTabs.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  SfSpacing.screen,
                  SfSpacing.lg,
                  SfSpacing.screen,
                  SfSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Paso 2 de 2',
                      style: SfTypography.caption.copyWith(color: SfColors.primaryLight),
                    ),
                    const SizedBox(height: SfSpacing.xxl),
                    const Center(child: _ReminderBell()),
                    const SizedBox(height: SfSpacing.lg),
                    Text(
                      'Activa los recordatorios',
                      textAlign: TextAlign.center,
                      style: SfTypography.h1,
                    ),
                    const SizedBox(height: SfSpacing.xs),
                    Text(
                      'Te avisamos un día antes de cada entrega y cuando el '
                      'asistente tenga tu plan del día.',
                      textAlign: TextAlign.center,
                      style: SfTypography.body.copyWith(color: SfColors.textSecondary),
                    ),
                    const SizedBox(height: SfSpacing.xl),
                    const ReminderPreviewCard(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SfSpacing.screen,
                SfSpacing.xs,
                SfSpacing.screen,
                SfSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SfButton(
                    label: 'Activar recordatorios',
                    onPressed: () => _goHome(context),
                  ),
                  const SizedBox(height: SfSpacing.xxs),
                  SfButton(
                    label: 'Ahora no',
                    variant: SfButtonVariant.ghost,
                    onPressed: () => _goHome(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Círculo violeta con la campana, que ilustra los recordatorios.
class _ReminderBell extends StatelessWidget {
  const _ReminderBell();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SfSpacing.xxl + SfSpacing.xl,
      height: SfSpacing.xxl + SfSpacing.xl,
      decoration: const BoxDecoration(
        color: SfColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.notifications_none_rounded,
        size: SfSpacing.xl,
        color: SfColors.textPrimary,
      ),
    );
  }
}
