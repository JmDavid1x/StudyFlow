import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// "Progreso semanal · 5 de 9 tareas" con su barra (Figma 12 y 16).
class WeeklyProgressCard extends StatelessWidget {
  const WeeklyProgressCard({super.key, required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Progreso semanal', style: SfTypography.title)),
              Text('$done de $total tareas', style: SfTypography.body.copyWith(color: SfColors.textSecondary)),
            ],
          ),
          const SizedBox(height: SfSpacing.sm),
          SfProgressBar(value: total == 0 ? 0 : done / total),
        ],
      ),
    );
  }
}
