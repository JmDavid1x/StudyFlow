import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/ui/widgets/subjects_prototype_data.dart';

/// Resumen de la pestaña Materias (Figma 21): promedio del semestre y
/// cantidad de materias.
class SemesterAverageCard extends StatelessWidget {
  const SemesterAverageCard({super.key, required this.subjects});

  final List<PrototypeSubject> subjects;

  @override
  Widget build(BuildContext context) {
    final average = subjects.isEmpty
        ? 0.0
        : subjects.fold<double>(0, (sum, subject) => sum + subject.grade) / subjects.length;

    return SfCard(
      highlighted: true,
      child: Row(
        children: [
          Container(
            width: SfSpacing.xl + SfSpacing.xs,
            height: SfSpacing.xl + SfSpacing.xs,
            decoration: BoxDecoration(
              color: SfColors.primary,
              borderRadius: BorderRadius.circular(SfRadius.md),
            ),
            child: const Icon(Icons.star_outline_rounded, color: SfColors.textPrimary),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Promedio del semestre', style: SfTypography.caption),
                Text('${average.toStringAsFixed(1)} de 5.0', style: SfTypography.h2),
              ],
            ),
          ),
          SfBadge(label: '${subjects.length} materias', tone: SfTone.primary),
        ],
      ),
    );
  }
}
