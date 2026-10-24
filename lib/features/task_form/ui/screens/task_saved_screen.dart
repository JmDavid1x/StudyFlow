import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form_data.dart';

/// Tarea del prototipo, para cuando se abre esta pantalla sin argumentos
/// (por ejemplo, desde el menú de desarrollo).
final _exampleTask = TaskFormData(
  title: 'Prototipo flujo principal',
  subject: DemoData.subjects.first,
  kind: TaskKind.project,
  date: DateTime(2026, 9, 23),
  time: const TimeOfDay(hour: 23, minute: 59),
  priority: TaskPriority.high,
  channel: DeliveryChannel.intu,
);

/// Tarea guardada (Figma 15). Confirma que la tarea quedó guardada y muestra
/// su resumen. Recibe un [TaskFormData] como argumento de la ruta.
class TaskSavedScreen extends StatelessWidget {
  const TaskSavedScreen({super.key});

  static const _checkSize = 92.0;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final task = args is TaskFormData ? args : _exampleTask;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xxl, SfSpacing.screen, SfSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: _checkSize,
                        height: _checkSize,
                        decoration: BoxDecoration(
                          color: SfColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: SfColors.primary.withValues(alpha: 0.45),
                              blurRadius: SfSpacing.xl,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded, size: 44, color: SfColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    Text('¡Tarea guardada!', textAlign: TextAlign.center, style: SfTypography.h1),
                    const SizedBox(height: SfSpacing.xs),
                    Text(
                      'La agregamos a tu Inicio y a tu calendario. Ya no depende de que '
                      'recuerdes dónde la anotaste.',
                      textAlign: TextAlign.center,
                      style: SfTypography.body.copyWith(color: SfColors.textSecondary),
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    _TaskSummaryCard(task: task),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.md),
              child: Column(
                children: [
                  SfButton(
                    label: 'Ver en Inicio',
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.main,
                      (_) => false,
                      arguments: AppTabs.home,
                    ),
                  ),
                  const SizedBox(height: SfSpacing.xs),
                  SfButton(
                    label: 'Crear otra tarea',
                    variant: SfButtonVariant.secondary,
                    // Reemplaza esta pantalla por un formulario vacío.
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.newTask),
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

/// Resumen de la tarea: materia, fecha, canal o lugar y recordatorio.
class _TaskSummaryCard extends StatelessWidget {
  const _TaskSummaryCard({required this.task});

  final TaskFormData task;

  @override
  Widget build(BuildContext context) {
    final date = task.date;
    final time = task.time;
    final when = [
      if (date != null) sfFormatDate(date),
      if (time != null) sfFormatTime(time),
    ].join(' · ');

    String? where;
    if (task.kind == TaskKind.exam) {
      if (task.place.isNotEmpty) where = 'Es en ${task.place}';
    } else if (task.channel != null) {
      where = 'Se entrega por ${task.channel!.label}';
    }

    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(task.title, style: SfTypography.title)),
              const SizedBox(width: SfSpacing.xs),
              SfBadge.priority(task.priority.label),
            ],
          ),
          const SizedBox(height: SfSpacing.xs),
          if (task.subject != null)
            _SummaryRow(
              icon: Icons.circle,
              iconColor: task.subject!.color,
              iconSize: SfSpacing.xs,
              text: '${task.subject!.name} · ${task.kind.label}',
            ),
          if (when.isNotEmpty) _SummaryRow(icon: Icons.event_outlined, text: when),
          if (where != null) _SummaryRow(icon: Icons.send_outlined, text: where),
          if (task.reminder && date != null)
            _SummaryRow(
              icon: Icons.alarm,
              text: 'Te recordamos el ${sfFormatDate(date.subtract(const Duration(days: 1)))}',
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.text,
    this.iconColor = SfColors.primaryLight,
    this.iconSize = 18,
  });

  final IconData icon;
  final String text;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SfSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
          const SizedBox(width: SfSpacing.xs),
          Expanded(
            child: Text(text, style: SfTypography.body.copyWith(color: SfColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
