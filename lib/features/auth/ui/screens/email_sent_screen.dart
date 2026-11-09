import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/auth/ui/bloc/auth_bloc.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_layout.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_messages.dart';

/// Correo enviado (Figma 07). Confirma a qué correo se mandó el enlace,
/// deja reenviarlo (pide otro a Supabase) y vuelve al inicio de sesión.
/// Recibe el correo (String) como argumento de la ruta.
class EmailSentScreen extends StatelessWidget {
  const EmailSentScreen({super.key});

  static const _iconCircle = SfSpacing.xxl * 2;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final email = args is String && args.isNotEmpty ? args : null;
    final destination = email ?? 'tu correo';
    final resending = context.select((AuthBloc bloc) => bloc.state.cargando(AccionAuth.recuperacion));

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (before, now) => now.accion == AccionAuth.recuperacion && before.estado != now.estado,
      listener: (context, state) {
        if (state.exito(AccionAuth.recuperacion)) showAuthInfo(context, 'Te enviamos otro enlace a $destination');
        if (state.error(AccionAuth.recuperacion)) showAuthError(context, state.mensaje);
      },
      child: AuthLayout(
      actions: [
        SfButton(
          label: 'Volver a iniciar sesión',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false),
        ),
        const SizedBox(height: SfSpacing.xxs),
        SfButton(
          label: 'Reenviar el enlace',
          variant: SfButtonVariant.ghost,
          isLoading: resending,
          onPressed: email == null || resending
              ? null
              : () => context.read<AuthBloc>().add(RecuperacionPedida(email)),
        ),
      ],
      children: [
        const SizedBox(height: SfSpacing.xl),
        Center(
          child: Container(
            width: _iconCircle,
            height: _iconCircle,
            decoration: const BoxDecoration(color: SfColors.primarySoft, shape: BoxShape.circle),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: SfSpacing.xxl,
              color: SfColors.primaryLight,
            ),
          ),
        ),
        const SizedBox(height: SfSpacing.lg),
        Text('Revisa tu correo', textAlign: TextAlign.center, style: SfTypography.display),
        const SizedBox(height: SfSpacing.xs),
        Text(
          'Enviamos un enlace a $destination. Ábrelo para crear una contraseña nueva.',
          textAlign: TextAlign.center,
          style: SfTypography.body.copyWith(color: SfColors.textSecondary),
        ),
        const SizedBox(height: SfSpacing.lg),
        SfCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: SfSpacing.lg - SfSpacing.xxs, color: SfColors.textSecondary),
              const SizedBox(width: SfSpacing.sm),
              Expanded(
                child: Text(
                  'Si no lo ves en unos minutos, revisa la carpeta de spam o correo no deseado.',
                  style: SfTypography.caption,
                ),
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }
}
