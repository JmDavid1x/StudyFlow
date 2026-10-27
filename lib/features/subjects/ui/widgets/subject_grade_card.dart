import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/ui/widgets/subjects_prototype_data.dart';

/// Nota actual contra la meta (Figma 22): anillo, meta, lo que falta y el
/// avance de lo evaluado.
///
/// Las cifras "4.7", "50 %" son las del prototipo; en el Sprint 2 se calculan.
class SubjectGradeCard extends StatelessWidget {
  const SubjectGradeCard({super.key, required this.subject});

  static const _maxGrade = 5.0;
  static const _evaluated = 0.5;

  final PrototypeSubject subject;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SfProgressRing(
                value: subject.grade / _maxGrade,
                size: SfSpacing.xxl * 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(subject.grade.toStringAsFixed(1), style: SfTypography.h1),
                    Text('de 5.0', style: SfTypography.caption),
                  ],
                ),
              ),
              const SizedBox(width: SfSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nota acumulada · 50 % evaluado', style: SfTypography.caption),
                    const SizedBox(height: SfSpacing.xxs),
                    Text.rich(
                      TextSpan(
                        text: 'Meta: ',
                        style: SfTypography.h2,
                        children: [
                          TextSpan(
                            text: subject.goal.toStringAsFixed(1),
                            style: SfTypography.h2.copyWith(color: SfColors.primaryLight),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SfSpacing.xxs),
                    Text(
                      'Necesitas 4.7 en el 50 % que falta',
                      style: SfTypography.caption.copyWith(color: SfColors.warningLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SfSpacing.md),
          Text('Evaluado: 50 % de la materia', style: SfTypography.caption),
          const SizedBox(height: SfSpacing.xs),
          const SfProgressBar(value: _evaluated),
        ],
      ),
    );
  }
}
