import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/home/data/home_repository_impl.dart';
import 'package:studyflow/features/home/domain/textos_inicio.dart';
import 'package:studyflow/features/home/ui/bloc/notifications_cubit.dart';
import 'package:studyflow/features/home/ui/widgets/notification_tile.dart';
import 'package:studyflow/features/tasks/data/tasks_repository_impl.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_navigation.dart';

/// Notificaciones (Figma 13): avisos agrupados por día. Tocar un aviso lo
/// marca como leído y abre lo que menciona; deslizarlo lo borra.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit(HomeRepositoryImpl(supabase), TasksRepositoryImpl(supabase))..cargar(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  Future<void> _open(BuildContext context, Notificacion notification) async {
    final cubit = context.read<NotificationsCubit>();
    if (notification.tipo == TipoNotificacion.planDelDia) {
      cubit.tocar(notification);
      await Navigator.pushNamed(context, AppRoutes.assistant);
    } else {
      final actividad = await cubit.tocar(notification);
      if (actividad == null || !context.mounted) return;
      await openTaskDetail(context, actividad);
    }
    // Al volver pudo cambiar algo (por ejemplo, se completó la tarea).
    await cubit.cargar();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsCubit, NotificationsState>(
      listenWhen: (previous, current) => previous.avisoId != current.avisoId,
      listener: (context, state) {
        if (state.aviso != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.aviso!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SfScreenHeader(title: 'Notificaciones'),
                Expanded(child: _content(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, NotificationsState state) {
    switch (state.estado) {
      case EstadoNotificaciones.cargando:
        return const SfLoadingState(message: 'Cargando tus avisos…');
      case EstadoNotificaciones.error:
        return Center(
          child: SingleChildScrollView(
            child: SfErrorState(
              message: state.mensaje ?? 'No pudimos cargar tus avisos.',
              onRetry: () => context.read<NotificationsCubit>().cargar(),
            ),
          ),
        );
      case EstadoNotificaciones.listo:
        break;
    }

    final notifications = state.notificaciones;
    if (notifications.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: SfEmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'Estás al día',
            message: 'Aquí te avisamos cuando algo esté por vencer o tu plan del día esté listo.',
            actionLabel: 'Volver al inicio',
            onAction: () =>
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false, arguments: AppTabs.home),
          ),
        ),
      );
    }

    // Ya vienen de la más reciente a la más vieja: se agrupan en ese orden.
    final ahora = state.ahora ?? DateTime.now();
    final groups = <String, List<Notificacion>>{};
    for (final notification in notifications) {
      groups.putIfAbsent(grupoDelDia(notification.programadaPara, ahora), () => []).add(notification);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(SfSpacing.screen, 0, SfSpacing.screen, SfSpacing.lg),
      children: [
        for (final MapEntry(key: day, value: items) in groups.entries) ...[
          const SizedBox(height: SfSpacing.xs),
          Text(day, style: SfTypography.label),
          const SizedBox(height: SfSpacing.xs),
          for (final notification in items)
            Padding(
              padding: const EdgeInsets.only(bottom: SfSpacing.sm),
              child: Dismissible(
                key: ValueKey(notification.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => context.read<NotificationsCubit>().borrar(notification),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: SfSpacing.lg),
                  child: const Icon(Icons.delete_outline_rounded, color: SfColors.danger),
                ),
                child: NotificationTile(notification: notification, onTap: () => _open(context, notification)),
              ),
            ),
        ],
      ],
    );
  }
}
