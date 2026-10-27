import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Ejemplo de aviso que recibirá el estudiante (Figma 10).
class ReminderPreviewCard extends StatelessWidget {
  const ReminderPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SfCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: SfSpacing.xl + SfSpacing.xs,
            height: SfSpacing.xl + SfSpacing.xs,
            decoration: BoxDecoration(
              color: SfColors.primary,
              borderRadius: BorderRadius.circular(SfRadius.md),
            ),
            child: const Icon(Icons.school_rounded, color: SfColors.textPrimary),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('StudyFlow', style: SfTypography.bodyStrong)),
                    Text('ahora', style: SfTypography.caption),
                  ],
                ),
                const SizedBox(height: SfSpacing.xxs),
                Text('Mañana vence: Taller 3 de SQL', style: SfTypography.bodyStrong),
                const SizedBox(height: SfSpacing.xxs),
                Text('Se entrega por INTU · 11:59 p. m.', style: SfTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
