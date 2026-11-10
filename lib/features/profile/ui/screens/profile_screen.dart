import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/assistant/domain/limite_consultas.dart';
import 'package:studyflow/features/auth/ui/bloc/auth_bloc.dart';
import 'package:studyflow/features/profile/data/profile_repository_impl.dart';
import 'package:studyflow/features/profile/domain/usecases/cargar_perfil.dart';
import 'package:studyflow/features/profile/ui/bloc/profile_cubit.dart';
import 'package:studyflow/features/profile/ui/widgets/profile_link_tile.dart';
import 'package:studyflow/features/subscription/data/subscription_repository_impl.dart';

/// Pestaña Perfil (Figma 25). La barra inferior la pone MainShell, que la
/// crea con `const ProfileScreen()`; por eso el Cubit se crea aquí adentro.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(
        ProfileRepositoryImpl(supabase),
        SubscriptionRepositoryImpl(supabase),
      )..cargar(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  /// Abre otra pantalla y, al volver, recarga (pudo cambiar el plan).
  Future<void> _push(BuildContext context, String route) async {
    final cubit = context.read<ProfileCubit>();
    await Navigator.pushNamed(context, route);
    await cubit.cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final resumen = state.resumen;
            if (state.estado == EstadoPerfil.cargando) {
              return const Center(
                child: SfLoadingState(message: 'Cargando tu perfil'),
              );
            }
            if (state.estado == EstadoPerfil.error || resumen == null) {
              return Center(
                child: SingleChildScrollView(
                  child: SfErrorState(
                    message: state.mensaje ?? 'No pudimos cargar tu perfil.',
                    onRetry: () => context.read<ProfileCubit>().cargar(),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<ProfileCubit>().cargar(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SfLargeTitle(title: 'Perfil'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        SfSpacing.screen,
                        0,
                        SfSpacing.screen,
                        SfSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AccountHeader(resumen: resumen),
                          const SizedBox(height: SfSpacing.lg),
                          _PlanCard(resumen: resumen),
                          const SizedBox(height: SfSpacing.lg),
                          Text('Cuenta', style: SfTypography.h2),
                          const SizedBox(height: SfSpacing.sm),
                          ProfileLinkTile(
                            icon: Icons.notifications_none_rounded,
                            title: 'Ajustes de notificaciones',
                            subtitle:
                                'Entregas, bloques de estudio y resumen semanal',
                            onTap: () =>
                                _push(context, AppRoutes.notificationSettings),
                          ),
                          const SizedBox(height: SfSpacing.xs),
                          ProfileLinkTile(
                            icon: Icons.auto_awesome_outlined,
                            title: 'StudyFlow Plus',
                            subtitle: resumen.esPlus
                                ? 'Ya tienes Plus'
                                : 'Consultas ilimitadas al asistente',
                            onTap: () => _push(context, AppRoutes.plus),
                          ),
                          const SizedBox(height: SfSpacing.xl),
                          SfButton(
                            label: 'Cerrar sesión',
                            icon: Icons.logout_rounded,
                            variant: SfButtonVariant.danger,
                            // El AuthBloc cierra la sesión y lleva al login.
                            onPressed: () => context.read<AuthBloc>().add(
                              const CerrarSesionPedido(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Inicial, nombre, correo, universidad y periodo activo.
class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.resumen});

  final ResumenPerfil resumen;

  @override
  Widget build(BuildContext context) {
    final perfil = resumen.perfil;
    final periodo = resumen.periodo;
    final meta = periodo?.metaPromedio;
    final detalle = [
      perfil.universidad?.nombre ?? 'Universidad sin registrar',
      if (perfil.programa != null) perfil.programa!,
      if (perfil.semestre != null) 'Semestre ${perfil.semestre}',
    ].join(' · ');

    return Column(
      children: [
        SfAvatar(name: perfil.nombre),
        const SizedBox(height: SfSpacing.sm),
        Text(
          perfil.nombre,
          textAlign: TextAlign.center,
          style: SfTypography.h1,
        ),
        const SizedBox(height: SfSpacing.xxs),
        Text(
          perfil.correo,
          style: SfTypography.body.copyWith(color: SfColors.textSecondary),
        ),
        Text(
          detalle,
          textAlign: TextAlign.center,
          style: SfTypography.caption.copyWith(color: SfColors.textSecondary),
        ),
        if (periodo != null) ...[
          const SizedBox(height: SfSpacing.xs),
          SfBadge(
            label: meta == null
                ? 'Periodo ${periodo.nombre}'
                : 'Periodo ${periodo.nombre} · meta ${meta.toStringAsFixed(1).replaceAll('.', ',')}',
            tone: SfTone.info,
          ),
        ],
      ],
    );
  }
}

/// Plan actual (gratis o Plus) con las consultas usadas esta semana.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.resumen});

  final ResumenPerfil resumen;

  @override
  Widget build(BuildContext context) {
    final limite = resumen.limite;
    final pruebaHasta = resumen.suscripcion?.pruebaHasta;
    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Plan actual', style: SfTypography.title)),
              SfBadge(
                label: resumen.esPlus ? 'StudyFlow Plus' : 'Plan gratis',
                tone: SfTone.primary,
              ),
            ],
          ),
          const SizedBox(height: SfSpacing.sm),
          if (resumen.esPlus)
            Text(
              pruebaHasta == null
                  ? 'Consultas ilimitadas al asistente.'
                  : 'Consultas ilimitadas. Tu prueba gratis va hasta el ${sfFormatDate(pruebaHasta)}.',
              style: SfTypography.caption.copyWith(
                color: SfColors.textSecondary,
              ),
            )
          else ...[
            SfProgressBar(value: limite.progreso),
            const SizedBox(height: SfSpacing.xs),
            Text(
              '${limite.usadas} de $consultasGratisPorSemana consultas gratis al asistente esta semana',
              style: SfTypography.caption.copyWith(
                color: SfColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
