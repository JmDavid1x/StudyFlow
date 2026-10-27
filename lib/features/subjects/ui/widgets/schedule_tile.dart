import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/ui/widgets/class_schedule.dart';

/// Fila de un horario agregado (Figma 09): día, horas, salón y botón para
/// quitarlo.
class ScheduleTile extends StatelessWidget {
  const ScheduleTile({super.key, required this.schedule, required this.onRemove});

  final ClassSchedule schedule;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      padding: const EdgeInsets.symmetric(
        horizontal: SfSpacing.md,
        vertical: SfSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: SfSpacing.xl + SfSpacing.xs,
            height: SfSpacing.xl + SfSpacing.xs,
            decoration: BoxDecoration(
              color: SfColors.primarySoft,
              borderRadius: BorderRadius.circular(SfRadius.md),
            ),
            child: const Icon(Icons.event_outlined, color: SfColors.primaryLight),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schedule.day, style: SfTypography.bodyStrong),
                Text(schedule.summary, style: SfTypography.caption),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: 'Quitar horario',
            icon: const Icon(Icons.close, color: SfColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
