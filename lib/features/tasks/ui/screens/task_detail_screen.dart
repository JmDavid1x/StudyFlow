import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/tasks/ui/widgets/confirm_sheet.dart';
import 'package:studyflow/features/tasks/ui/widgets/detail_info_card.dart';
import 'package:studyflow/features/tasks/ui/widgets/study_blocks_card.dart';
import 'package:studyflow/features/tasks/ui/widgets/subject_pill.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_completed_sheet.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_extras.dart';

/// Detalle de tarea (Figma 18) con sus hojas: S1 Tarea completada, S2
/// Eliminar tarea y S8 Tarea vencida (se abre sola si la tarea venció).
///
/// Recibe la tarea como argumento de la ruta (un DemoTask). Sin argumento
/// muestra la tarea del prototipo.
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  /// Solo interfaz: en el Sprint 2 el estado se guarda en Supabase.
  bool? _done;
  bool _notDelivered = false;

  DemoTask get _task {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is DemoTask ? args : TaskExtras.prototypeTask;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && TaskExtras.isOverdue(_task)) _askIfDelivered();
    });
  }

  Future<void> _complete() async {
    setState(() => _done = true);
    await showTaskCompletedSheet(context, _task);
  }

  void _askIfDelivered() {
    final task = _task;
    showSfBottomSheet<void>(
      context,
      builder: (sheetContext) => ConfirmSheet(
        icon: Icons.warning_amber_rounded,
        title: '¿Entregaste el ${task.title.split(':').first}?',
        message: TaskExtras.of(task).overdueMessage ?? 'Cuéntanos para mantener tu lista al día.',
        confirm: SfButton(
          label: 'Sí, la entregué',
          icon: Icons.check_rounded,
          onPressed: () {
            Navigator.pop(sheetContext);
            setState(() => _done = true);
          },
        ),
        cancelLabel: 'No la entregué',
        onCancel: () {
          Navigator.pop(sheetContext);
          setState(() => _notDelivered = true);
        },
        footnote: 'Si no la entregaste, pasa a "No entregadas" y deja de contar como pendiente.',
      ),
    );
  }

  void _confirmDelete() {
    showSfBottomSheet<void>(
      context,
      builder: (sheetContext) => ConfirmSheet(
        icon: Icons.delete_outline_rounded,
        title: '¿Eliminar esta tarea?',
        message: 'Se borrará "${_task.title}" y su recordatorio. No se puede deshacer.',
        confirm: SfButton(
          label: 'Eliminar tarea',
          variant: SfButtonVariant.danger,
          onPressed: () {
            Navigator.pop(sheetContext);
            Navigator.pop(context);
          },
        ),
        cancelLabel: 'Cancelar',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;
    final details = TaskExtras.of(task);
    final done = _done ?? task.done;
    final overdue = TaskExtras.isOverdue(task) && !done;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SfScreenHeader(
              title: 'Detalle de tarea',
              trailing: SfIconButton(
                icon: Icons.edit_outlined,
                tooltip: 'Editar',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.editTask, arguments: task),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: SfSpacing.xs,
                      runSpacing: SfSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SubjectPill(name: task.subject, color: task.color),
                        if (done) const SfBadge(label: 'Completada', tone: SfTone.success),
                        if (_notDelivered) const SfBadge(label: 'No entregada', tone: SfTone.danger),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.sm),
                    Text(task.title, style: SfTypography.h1),
                    const SizedBox(height: SfSpacing.md),
                    DetailInfoCard(
                      rows: [
                        DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Entrega',
                          value: details.dueLabel ?? sentenceCase(task.due),
                          note: done ? null : details.timeLeft,
                          noteColor: overdue ? SfColors.danger : SfColors.warning,
                        ),
                        if (details.channel != null)
                          DetailRow(icon: Icons.send_outlined, label: 'Se entrega por', value: details.channel!),
                        DetailRow(icon: Icons.flag_outlined, label: 'Prioridad', value: sentenceCase(task.priority)),
                        if (details.gradePart != null)
                          DetailRow(icon: Icons.percent_rounded, label: 'Parte de la nota', value: details.gradePart!),
                        if (details.reminder != null)
                          DetailRow(icon: Icons.alarm_rounded, label: 'Recordatorio', value: details.reminder!),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    StudyBlocksCard(blocks: details.blocks, color: task.color),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.md),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DeleteButton(onPressed: _confirmDelete),
                    const SizedBox(width: SfSpacing.sm),
                    Expanded(
                      child: SfButton(
                        label: done ? 'Completada' : 'Marcar como completada',
                        icon: Icons.check_rounded,
                        // Si venció, primero se pregunta si se entregó (S8).
                        onPressed: done ? null : (overdue ? _askIfDelivered : _complete),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón cuadrado con la papelera, al lado de la acción principal.
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.lg);
    return Tooltip(
      message: 'Eliminar tarea',
      child: Material(
        color: SfColors.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Container(
            width: SfSpacing.xxl + SfSpacing.xxs,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: SfColors.border),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: SfColors.danger),
          ),
        ),
      ),
    );
  }
}
