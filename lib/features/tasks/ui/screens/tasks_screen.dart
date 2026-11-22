import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/realtime/recargar_en_vivo.dart';
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
      create: (_) => sl<TasksBloc>()..add(const TareasPedidas()),
      // Si cambia algo desde otro dispositivo, la lista se actualiza sola.
      child: Builder(
        builder: (context) => RecargarEnVivo(
          tablas: const {'actividades', 'calificaciones'},
          alCambiar: () => context.read<TasksBloc>().add(const CambioEnVivo()),
          child: const _TasksView(),
        ),
      ),
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

  void _newSubject(BuildContext context) => _thenReload(context, Navigator.pushNamed(context, AppRoutes.newSubject));

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
        final alDia = state.vacio == VacioTareas.todoAlDia && state.filtro != FiltroTareas.completadas;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Todo cerrado: se celebra arriba y en "Todas" siguen las completadas.
            if (alDia) ...[const SizedBox(height: SfSpacing.lg), _allDone(context)],
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
            if (secciones.isEmpty && !alDia) ...[const SizedBox(height: SfSpacing.lg), _emptyState(context, state)],
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

  /// Todas las tareas están cerradas.
  Widget _allDone(BuildContext context) => SfCard(
    child: SfEmptyState(
      icon: Icons.celebration_outlined,
      title: '¡Estás al día!',
      message: 'Completaste todas tus tareas. Agrega la próxima apenas te la dejen.',
      actionLabel: 'Agregar tarea',
      onAction: () => _newTask(context),
    ),
  );

  /// Qué decir cuando no hay nada que mostrar con el chip elegido.
  Widget _emptyState(BuildContext context, TasksState state) {
    return SfCard(
      child: switch ((state.vacio, state.filtro)) {
        (VacioTareas.sinMaterias, _) => SfEmptyState(
          icon: Icons.school_outlined,
          title: 'Primero agrega tus materias',
          message: 'Cada tarea va dentro de una materia. Crea la primera y luego agrega sus entregas.',
          actionLabel: 'Agregar mi primera materia',
          onAction: () => _newSubject(context),
        ),
        (VacioTareas.sinTareas, _) => SfEmptyState(
          icon: Icons.edit_calendar_outlined,
          title: 'Aún no tienes tareas',
          message: 'Agrega la primera entrega y te recordamos antes de que venza.',
          actionLabel: 'Agregar mi primera tarea',
          onAction: () => _newTask(context),
        ),
        (_, FiltroTareas.completadas) => const SfEmptyState(
          icon: Icons.task_alt_rounded,
          title: 'Aún no completas tareas',
          message: 'Toca el círculo de una tarea cuando la termines y aparecerá aquí.',
        ),
        // Hay pendientes, pero no con este chip.
        (_, FiltroTareas.hoy) => const SfEmptyState(
          icon: Icons.wb_sunny_outlined,
          title: 'Nada vence hoy',
          message: 'Mira "Todas" para adelantar lo que viene.',
        ),
        _ => const SfEmptyState(
          icon: Icons.event_available_outlined,
          title: 'Nada para esta semana',
          message: 'Tus próximas entregas están en "Todas".',
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
