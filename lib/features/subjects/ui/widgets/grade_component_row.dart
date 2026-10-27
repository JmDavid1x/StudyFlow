import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/ui/widgets/subjects_prototype_data.dart';

/// Fila de "Cómo se calcula tu nota" (Figma 22): componente, porcentaje y
/// resultado.
class GradeComponentRow extends StatelessWidget {
  const GradeComponentRow({super.key, required this.component});

  final PrototypeComponent component;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: SfSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SfColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${component.name} · ${component.percent} %',
              style: SfTypography.body.copyWith(color: SfColors.textSecondary),
            ),
          ),
          Text(component.result, style: SfTypography.bodyStrong),
        ],
      ),
    );
  }
}
