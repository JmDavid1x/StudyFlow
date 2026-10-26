import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/tasks/ui/widgets/overdue_task_tile.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_badge.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_extras.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_navigation.dart';

enum _Filter { all, today, week, done }

/// Pestaña Tareas (Figma 17). Lista todas las actividades por sección y los
/// chips de arriba filtran cuáles se ven. La barra inferior la pone MainShell.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  _Filter _filter = _Filter.all;

  /// Títulos de las tareas que el usuario marcó o desmarcó en esta pantalla.
  /// Solo interfaz: en el Sprint 2 esto se guarda en Supabase.
  final Set<String> _toggled = {};

  bool _isDone(DemoTask task) => task.done != _toggled.contains(task.title);

  void _toggle(DemoTask task) {
    setState(() {
      if (!_toggled.remove(task.title)) _toggled.add(task.title);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pending = DemoData.tasks.where((task) => !_isDone(task));
    final today = pending.where((task) => task.due.startsWith('hoy')).toList();
    final week = pending.where((task) => !task.due.startsWith('hoy')).toList();
    final done = DemoData.tasks.where(_isDone).toList();

    final showOverdue = _filter == _Filter.all || _filter == _Filter.today;
    final showToday = _filter != _Filter.done;
    final showWeek = _filter == _Filter.all || _filter == _Filter.week;
    final showDone = _filter == _Filter.all || _filter == _Filter.done;

    final isEmpty = !showOverdue &&
        (!showToday || today.isEmpty) &&
        (!showWeek || week.isEmpty) &&
        (!showDone || done.isEmpty);

    return Scaffold(
      floatingActionButton: SfFab(
        tooltip: 'Nueva tarea',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.newTask),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          // Espacio abajo para que el botón + no tape la última fila.
          padding: const EdgeInsets.only(bottom: SfSpacing.xxl * 2),
          children: [
            const SfLargeTitle(title: 'Tareas'),
            SfChipBar<_Filter>(
              options: const [
                (_Filter.all, 'Todas'),
                (_Filter.today, 'Hoy'),
                (_Filter.week, 'Esta semana'),
                (_Filter.done, 'Completadas'),
              ],
              selected: _filter,
              onChanged: (filter) => setState(() => _filter = filter),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SfSpacing.screen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showOverdue)
                    _Section(
                      title: 'Vencidas',
                      children: [
                        OverdueTaskTile(
                          task: TaskExtras.overdue,
                          onTap: () => openTaskDetail(context, TaskExtras.overdue),
                        ),
                      ],
                    ),
                  if (showToday && today.isNotEmpty)
                    _Section(title: 'Hoy', children: [for (final task in today) _tile(task)]),
                  if (showWeek && week.isNotEmpty)
                    _Section(title: 'Esta semana', children: [for (final task in week) _tile(task)]),
                  if (showDone && done.isNotEmpty)
                    _Section(title: 'Completadas', children: [for (final task in done) _tile(task)]),
                  if (isEmpty) ...[
                    const SizedBox(height: SfSpacing.lg),
                    _emptyState(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(DemoTask task) {
    final done = _isDone(task);
    return SfTaskTile(
      title: task.title,
      subtitle: '${task.subject} · ${task.due}',
      subjectColor: task.color,
      done: done,
      trailing: done ? null : TaskBadge(task: task),
      onTap: () => openTaskDetail(context, task),
      onToggle: () => _toggle(task),
    );
  }

  Widget _emptyState() {
    return SfCard(
      child: switch (_filter) {
        _Filter.done => const SfEmptyState(
            icon: Icons.task_alt_rounded,
            title: 'Aún no completas tareas',
            message: 'Toca el círculo de una tarea cuando la termines y aparecerá aquí.',
          ),
        _ => SfEmptyState(
            icon: Icons.event_available_outlined,
            title: 'No tienes tareas pendientes',
            message: 'Agrega una entrega y te recordamos antes de que venza.',
            actionLabel: 'Agregar tarea',
            onAction: () => Navigator.pushNamed(context, AppRoutes.newTask),
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
        for (final child in children) ...[
          child,
          const SizedBox(height: SfSpacing.sm),
        ],
      ],
    );
  }
}
