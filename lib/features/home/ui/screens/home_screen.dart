import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/home/data/home_repository_impl.dart';
import 'package:studyflow/features/home/domain/textos_inicio.dart';
import 'package:studyflow/features/home/ui/bloc/home_cubit.dart';
import 'package:studyflow/features/home/ui/widgets/pending_block_banner.dart';
import 'package:studyflow/features/home/ui/widgets/today_plan_card.dart';
import 'package:studyflow/features/home/ui/widgets/weekly_progress_card.dart';
import 'package:studyflow/features/tasks/data/tasks_repository_impl.dart';
import 'package:studyflow/features/tasks/domain/textos_actividad.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_badge.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_navigation.dart';

/// Texto de "Tu plan de hoy" mientras no se lea de `planes_estudio`
/// (esa tabla la llena el asistente, que no es de esta parte).
const _planSinDatos = 'Pídele al asistente que ordene tus pendientes de hoy y reserve tiempo para lo que viene.';

/// Pestaña Inicio (Figma 11 · 12 · 16): resumen de la semana, el plan del
/// asistente y las tareas de hoy y de los próximos días. La barra inferior la
/// pone MainShell (que la crea con `const HomeScreen()`).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(HomeRepositoryImpl(supabase), TasksRepositoryImpl(supabase))..cargar(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  /// Abre otra pantalla y, al volver, recarga Inicio (pudo cambiar algo).
  Future<void> _thenReload(BuildContext context, Future<void> navigation) async {
    final cubit = context.read<HomeCubit>();
    await navigation;
    await cubit.cargar();
  }

  void _push(BuildContext context, String route, {Object? arguments}) =>
      _thenReload(context, Navigator.pushNamed(context, route, arguments: arguments));

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (previous, current) => previous.avisoId != current.avisoId,
      listener: (context, state) {
        if (state.aviso != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.aviso!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          floatingActionButton: SfFab(tooltip: 'Nueva tarea', onPressed: () => _push(context, AppRoutes.newTask)),
          body: SafeArea(
            bottom: false,
            child: ListView(
              // Espacio abajo para que el botón + no tape la última fila.
              padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.md, SfSpacing.screen, SfSpacing.xxl * 2),
              children: _content(context, state),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _content(BuildContext context, HomeState state) {
    final ahora = state.ahora ?? DateTime.now();
    final resumen = state.resumen;

    if (state.estado == EstadoInicio.cargando || resumen == null) {
      return [
        _Greeting(date: fechaDeHoy(ahora), name: state.nombre, showAssistant: false, hasNews: false),
        const SizedBox(height: SfSpacing.xxl),
        if (state.estado == EstadoInicio.error)
          SfCard(
            child: SfErrorState(
              message: state.mensaje ?? 'No pudimos cargar tu inicio.',
              onRetry: () => context.read<HomeCubit>().cargar(),
            ),
          )
        else
          const SfLoadingState(message: 'Cargando tu semana…'),
      ];
    }

    final empty = resumen.sinActividades;
    final pendingBlock = resumen.bloquePendienteAyer;
    final (examValue, examCaption) = tarjetaExamen(resumen.proximoExamen, ahora);

    return [
      _Greeting(
        date: fechaDeHoy(ahora),
        name: state.nombre,
        showAssistant: !empty,
        hasNews: resumen.hayNovedades,
        onNotifications: () => _push(context, AppRoutes.notifications),
      ),
      if (pendingBlock != null) ...[
        const SizedBox(height: SfSpacing.md),
        PendingBlockBanner(
          activityTitle: pendingBlock.actividadTitulo ?? 'Bloque de estudio',
          onTap: () => _push(context, AppRoutes.studyBlock, arguments: pendingBlock),
        ),
      ],
      const SizedBox(height: SfSpacing.md),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SfStatCard(value: '${resumen.entregasSemana}', caption: 'entregas esta semana'),
            ),
            const SizedBox(width: SfSpacing.xs),
            Expanded(
              child: SfStatCard(value: examValue, caption: examCaption),
            ),
            const SizedBox(width: SfSpacing.xs),
            Expanded(
              child: SfStatCard(value: horasTexto(resumen.horasPlaneadas), caption: 'de estudio planeadas'),
            ),
          ],
        ),
      ),
      if (empty) ...[
        const SizedBox(height: SfSpacing.xl),
        SfEmptyState(
          icon: Icons.edit_calendar_outlined,
          title: 'Aún no tienes entregas',
          message: 'Agrega la primera y te recordamos antes de que venza.',
          actionLabel: 'Agregar mi primera entrega',
          onAction: () => _push(context, AppRoutes.newTask),
        ),
      ] else ...[
        const SizedBox(height: SfSpacing.md),
        WeeklyProgressCard(done: resumen.completadasSemana, total: resumen.totalSemana),
        const SizedBox(height: SfSpacing.md),
        TodayPlanCard(plan: _planSinDatos, onTalk: () => _push(context, AppRoutes.assistant)),
        const SizedBox(height: SfSpacing.lg),
        SfSectionHeader(
          title: 'Prioridades de hoy',
          actionLabel: 'Ver todas',
          onAction: () =>
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false, arguments: AppTabs.tasks),
        ),
        const SizedBox(height: SfSpacing.xs),
        if (resumen.prioridadesHoy.isEmpty)
          const SfCard(
            child: SfEmptyState(
              icon: Icons.wb_sunny_outlined,
              title: 'Nada vence hoy',
              message: 'Adelanta algo de los próximos días o agrega una tarea con el botón +.',
            ),
          )
        else
          for (final actividad in resumen.prioridadesHoy) _tile(context, actividad, ahora),
        const SizedBox(height: SfSpacing.md),
        const SfSectionHeader(title: 'Próximas'),
        const SizedBox(height: SfSpacing.xs),
        if (resumen.proximas.isEmpty)
          const SfCard(
            child: SfEmptyState(
              icon: Icons.event_available_outlined,
              title: 'Nada para los próximos días',
              message: 'Cuando agregues una entrega, aparecerá aquí.',
            ),
          )
        else
          for (final actividad in resumen.proximas) _tile(context, actividad, ahora),
      ],
    ];
  }

  Widget _tile(BuildContext context, Actividad actividad, DateTime ahora) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SfSpacing.sm),
      child: SfTaskTile(
        title: actividad.titulo,
        subtitle: subtituloActividad(actividad, ahora),
        subjectColor: actividad.materiaColor ?? SfColors.primaryLight,
        trailing: TaskBadge(actividad: actividad),
        onTap: () => _thenReload(context, openTaskDetail(context, actividad)),
        onToggle: () => context.read<HomeCubit>().marcar(actividad),
      ),
    );
  }
}

/// Fecha, saludo y los botones del asistente y de notificaciones.
class _Greeting extends StatelessWidget {
  const _Greeting({
    required this.date,
    required this.name,
    required this.showAssistant,
    required this.hasNews,
    this.onNotifications,
  });

  /// "Lunes, 9 de noviembre"
  final String date;

  /// Nulo mientras carga el perfil: dice solo "Hola".
  final String? name;
  final bool showAssistant;
  final bool hasNews;
  final VoidCallback? onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: SfTypography.caption),
              const SizedBox(height: SfSpacing.xxs),
              Text.rich(
                TextSpan(
                  text: name == null ? 'Hola' : 'Hola, ',
                  children: [
                    if (name != null)
                      TextSpan(
                        text: name,
                        style: SfTypography.display.copyWith(color: SfColors.primaryLight),
                      ),
                  ],
                ),
                style: SfTypography.display,
              ),
            ],
          ),
        ),
        if (showAssistant) ...[
          SfIconButton(
            icon: Icons.auto_awesome,
            tooltip: 'Asistente',
            filled: true,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.assistant),
          ),
          const SizedBox(width: SfSpacing.xs),
        ],
        SfIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notificaciones',
          showDot: hasNews,
          onPressed: onNotifications ?? () => Navigator.pushNamed(context, AppRoutes.notifications),
        ),
      ],
    );
  }
}
