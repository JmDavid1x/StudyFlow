import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/assistant/ui/widgets/assistant_demo.dart';
import 'package:studyflow/features/assistant/ui/widgets/suggested_order_card.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/demo_agenda.dart';

/// S4 Plan agregado. Muestra las actividades en el orden sugerido y, debajo
/// de cada una, sus bloques de estudio con día y hora.
Future<void> showPlanAddedSheet(BuildContext context, List<PlanStep> steps) {
  return showSfBottomSheet<void>(
    context,
    builder: (sheetContext) => SfResultSheet(
      title: 'Plan agregado',
      message: 'Tus bloques de estudio ya están en el calendario, en este orden.',
      primaryLabel: 'Ver calendario',
      onPrimary: () => Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (_) => false,
        arguments: AppTabs.calendar,
      ),
      secondaryLabel: 'Volver al chat',
      onSecondary: () => Navigator.pop(sheetContext),
      child: steps.isEmpty
          ? const SfEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'No se agregó ningún bloque',
              message: 'Pídele al asistente un orden sugerido para crear tus bloques.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, step) in steps.indexed) _PlanStepItem(number: index + 1, step: step),
              ],
            ),
    ),
  );
}

class _PlanStepItem extends StatelessWidget {
  const _PlanStepItem({required this.number, required this.step});

  final int number;
  final PlanStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NumberedTaskRow(
          number: number,
          title: step.task.title,
          subtitle: '${step.task.subject} · ${step.task.due}',
          color: step.task.color,
        ),
        for (final block in step.blocks)
          Padding(
            padding: const EdgeInsets.only(left: SfSpacing.xxl, bottom: SfSpacing.xs),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: SfSpacing.md, color: SfColors.info),
                const SizedBox(width: SfSpacing.xs),
                Expanded(
                  child: Text(
                    '${sfFormatDate(block.day)} · ${formatTimeRange(block.start, block.end)}',
                    style: SfTypography.caption.copyWith(color: SfColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: SfSpacing.xs),
      ],
    );
  }
}
