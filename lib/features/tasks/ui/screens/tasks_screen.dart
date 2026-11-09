import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/tasks/data/tasks_repository_impl.dart';
import 'package:studyflow/features/tasks/domain/filtros_tareas.dart';
import 'package:studyflow/features/tasks/domain/textos_actividad.dart';
import 'package:studyflow/features/tasks/ui/bloc/tasks_bloc.dart';
import 'package:studyflow/features/tasks/ui/widgets/overdue_task_tile.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_badge.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_navigation.dart';

/// Pestaña Tareas (Figma 17). Lista las actividades del periodo por sección
/// y los chips de arriba filtran cuáles se ven. La barra inferior la pone
/// MainShell (que la crea con `const TasksScreen()`).
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TasksBloc(TasksRepositoryImpl(supabase))..add(const TareasPedidas()),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView();

  /// Abre otra pantalla y, al volver, recarga la lista (pudo cambiar algo).
  Future<void> _thenReload(BuildContext context, Future<void> navigation) async {
    final bloc = context.read<TasksBloc>();
    await navigation;
    bloc.add(const TareasPedidas());
  }

  void _newTask(BuildContext context) => _thenReload(context, Navigator.pushNamed(context, AppRoutes.newTask));

  void _open(BuildContext context, Actividad actividad) => _thenReload(context, openTaskDetail(context, actividad));

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TasksBloc, TasksState>(
      listenWhen: (previous, current) => previous.avisoId != current.avisoId,
      listener: (context, state) {
        if (state.aviso != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.aviso!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          floatingActionButton: SfFab(tooltip: 'Nueva tarea', onPressed: () => _newTask(context)),
          body: SafeArea(
            bottom: false,
            child: ListView(
              // Espacio abajo para que el botón + no tape la última fila.
              padding: const EdgeInsets.only(bottom: SfSpacing.xxl * 2),
              children: [
                const SfLargeTitle(title: 'Tareas'),
                SfChipBar<FiltroTareas>(
                  options: const [
                    (FiltroTareas.todas, 'Todas'),
                    (FiltroTareas.hoy, 'Hoy'),
                    (FiltroTareas.semana, 'Esta semana'),
                    (FiltroTareas.completadas, 'Completadas'),
                  ],
                  selected: state.filtro,
                  onChanged: (filtro) => context.read<TasksBloc>().add(FiltroCambiado(filtro)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SfSpacing.screen),
                  child: _content(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, TasksState state) {
    switch (state.estado) {
      case EstadoTareas.cargando:
        return const Padding(
          padding: EdgeInsets.only(top: SfSpacing.xxl),
          child: SfLoadingState(message: 'Cargando tus tareas…'),
        );
      case EstadoTareas.error:
        return Padding(
          padding: const EdgeInsets.only(top: SfSpacing.lg),
          child: SfCard(
            child: SfErrorState(
              message: state.mensaje ?? 'No pudimos cargar tus tareas.',
              onRetry: () => context.read<TasksBloc>().add(const TareasPedidas()),
            ),
          ),
        );
      case EstadoTareas.vacio:
      case EstadoTareas.listo:
        final ahora = state.ahora ?? DateTime.now();
        final secciones = state.secciones;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final seccion in secciones)
              _Section(
                title: seccion.titulo,
                children: [
                  for (final actividad in seccion.actividades)
                    seccion.vencidas
                        ? OverdueTaskTile(
                            title: actividad.titulo,
                            subtitle: subtituloActividad(actividad, ahora),
                            onTap: () => _open(context, actividad),
                          )
                        : _tile(context, actividad, ahora),
                ],
              ),
            if (secciones.isEmpty) ...[const SizedBox(height: SfSpacing.lg), _emptyState(context, state.filtro)],
          ],
        );
    }
  }

  Widget _tile(BuildContext context, Actividad actividad, DateTime ahora) {
    final done = actividad.estado.estaCerrada;
    return SfTaskTile(
      title: actividad.titulo,
      subtitle: subtituloActividad(actividad, ahora),
      subjectColor: actividad.materiaColor ?? SfColors.primaryLight,
      done: done,
      trailing: done ? null : TaskBadge(actividad: actividad),
      onTap: () => _open(context, actividad),
      // Cerrada ya no se reabre desde la lista.
      onToggle: done ? null : () => context.read<TasksBloc>().add(CirculoTocado(actividad)),
    );
  }

  Widget _emptyState(BuildContext context, FiltroTareas filtro) {
    return SfCard(
      child: switch (filtro) {
        FiltroTareas.completadas => const SfEmptyState(
          icon: Icons.task_alt_rounded,
          title: 'Aún no completas tareas',
          message: 'Toca el círculo de una tarea cuando la termines y aparecerá aquí.',
        ),
        _ => SfEmptyState(
          icon: Icons.event_available_outlined,
          title: 'No tienes tareas pendientes',
          message: 'Agrega una entrega y te recordamos antes de que venza.',
          actionLabel: 'Agregar tarea',
          onAction: () => _newTask(context),
        ),
      },
    );
  }
}

/// Título de sección y sus filas, separadas como en Figma 17.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: SfSpacing.md),
        SfSectionHeader(title: title),
        const SizedBox(height: SfSpacing.xs),
        for (final child in children) ...[child, const SizedBox(height: SfSpacing.sm)],
      ],
    );
  }
}
