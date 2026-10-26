import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Materia de una actividad, con su color, arriba del título (Figma 18 y 29).
class SubjectPill extends StatelessWidget {
  const SubjectPill({super.key, required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.sm, vertical: SfSpacing.xxs + 2),
      decoration: BoxDecoration(
        color: SfColors.surface,
        borderRadius: BorderRadius.circular(SfRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: SfSpacing.xs,
            height: SfSpacing.xs,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: SfSpacing.xs),
          Flexible(child: Text(name, overflow: TextOverflow.ellipsis, style: SfTypography.bodyStrong)),
        ],
      ),
    );
  }
}
