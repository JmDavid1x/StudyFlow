import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/assistant/ui/widgets/assistant_demo.dart';

/// Tarjeta "Este es tu orden sugerido" con las actividades numeradas. El
/// botón solo se muestra en la última respuesta, para que haya una sola
/// acción principal en la pantalla.
class SuggestedOrderCard extends StatelessWidget {
  const SuggestedOrderCard({super.key, required this.steps, this.onAddToCalendar});

  final List<PlanStep> steps;
  final VoidCallback? onAddToCalendar;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Este es tu orden sugerido', style: SfTypography.title),
          const SizedBox(height: SfSpacing.sm),
          if (steps.isEmpty)
            const SfEmptyState(
              icon: Icons.event_available_outlined,
              title: 'No tienes actividades pendientes',
              message: 'Agrega una tarea y pídeme de nuevo tu orden sugerido.',
            )
          else
            for (final (index, step) in steps.indexed)
              NumberedTaskRow(
                number: index + 1,
                title: step.task.title,
                subtitle: '${step.task.subject} · ${step.task.due}',
                color: step.task.color,
              ),
          if (onAddToCalendar != null && steps.isNotEmpty) ...[
            const SizedBox(height: SfSpacing.xs),
            SfButton(
              label: 'Agregar plan al calendario',
              icon: Icons.calendar_month_outlined,
              onPressed: onAddToCalendar,
            ),
          ],
        ],
      ),
    );
  }
}

/// Fila con el número de la actividad en un círculo del color de su materia.
class NumberedTaskRow extends StatelessWidget {
  const NumberedTaskRow({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final int number;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SfSpacing.sm),
      child: Row(
        children: [
          Container(
            width: SfSpacing.xl,
            height: SfSpacing.xl,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Text('$number', style: SfTypography.number.copyWith(color: color)),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SfTypography.bodyStrong),
                Text(subtitle, style: SfTypography.caption.copyWith(color: SfColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
