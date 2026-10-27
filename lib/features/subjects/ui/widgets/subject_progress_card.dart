import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/ui/widgets/subjects_prototype_data.dart';

/// Tarjeta de una materia en la pestaña Materias (Figma 21): color, nombre,
/// profesor, nota actual, meta y barra de avance hacia 5.0.
class SubjectProgressCard extends StatelessWidget {
  const SubjectProgressCard({super.key, required this.subject, this.onTap});

  static const _maxGrade = 5.0;

  final PrototypeSubject subject;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: SfSpacing.xxs,
                  decoration: BoxDecoration(
                    color: subject.color,
                    borderRadius: BorderRadius.circular(SfRadius.sm),
                  ),
                ),
                const SizedBox(width: SfSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(subject.name, style: SfTypography.bodyStrong),
                      const SizedBox(height: SfSpacing.xxs),
                      Text(subject.professor, style: SfTypography.caption),
                    ],
                  ),
                ),
                const SizedBox(width: SfSpacing.xs),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(subject.grade.toStringAsFixed(1), style: SfTypography.h2),
                    Text('meta ${subject.goal.toStringAsFixed(1)}', style: SfTypography.caption),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: SfSpacing.sm),
          SfProgressBar(value: subject.grade / _maxGrade, color: subject.color),
        ],
      ),
    );
  }
}
