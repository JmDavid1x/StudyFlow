import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/assistant/ui/widgets/assistant_demo.dart';
import 'package:studyflow/features/profile/ui/widgets/profile_demo.dart';
import 'package:studyflow/features/profile/ui/widgets/profile_link_tile.dart';

/// Pestaña Perfil (Figma 25). La barra inferior la pone MainShell.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SfLargeTitle(title: 'Perfil'),
              Padding(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, 0, SfSpacing.screen, SfSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _AccountHeader(),
                    const SizedBox(height: SfSpacing.lg),
                    const _PlanCard(),
                    const SizedBox(height: SfSpacing.lg),
                    Text('Cuenta', style: SfTypography.h2),
                    const SizedBox(height: SfSpacing.sm),
                    ProfileLinkTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Ajustes de notificaciones',
                      subtitle: 'Entregas, bloques de estudio y resumen semanal',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.notificationSettings),
                    ),
                    const SizedBox(height: SfSpacing.xs),
                    ProfileLinkTile(
                      icon: Icons.auto_awesome_outlined,
                      title: 'StudyFlow Plus',
                      subtitle: 'Consultas ilimitadas al asistente',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.plus),
                    ),
                    const SizedBox(height: SfSpacing.xl),
                    SfButton(
                      label: 'Cerrar sesión',
                      icon: Icons.logout_rounded,
                      variant: SfButtonVariant.danger,
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (_) => false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inicial, nombre, correo y universidad.
class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SfAvatar(name: ProfileDemo.name),
        const SizedBox(height: SfSpacing.sm),
        Text(ProfileDemo.name, style: SfTypography.h1),
        const SizedBox(height: SfSpacing.xxs),
        Text(ProfileDemo.email, style: SfTypography.body.copyWith(color: SfColors.textSecondary)),
        Text(ProfileDemo.university, style: SfTypography.caption.copyWith(color: SfColors.textSecondary)),
      ],
    );
  }
}

/// Plan actual con las consultas gratis usadas esta semana.
class _PlanCard extends StatelessWidget {
  const _PlanCard();

  @override
  Widget build(BuildContext context) {
    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Plan actual', style: SfTypography.title)),
              const SfBadge(label: ProfileDemo.plan, tone: SfTone.primary),
            ],
          ),
          const SizedBox(height: SfSpacing.sm),
          const SfProgressBar(value: AssistantDemo.freeUsed / AssistantDemo.freeLimit),
          const SizedBox(height: SfSpacing.xs),
          Text(
            '${AssistantDemo.freeUsed} de ${AssistantDemo.freeLimit} consultas gratis al asistente esta semana',
            style: SfTypography.caption.copyWith(color: SfColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
