import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_radius.dart';
import 'package:studyflow/core/design_system/tokens/sf_typography.dart';

/// Tono de una insignia. Cada tono significa algo; no se elige por gusto.
enum SfTone { primary, success, warning, danger, info, neutral }

extension SfToneColor on SfTone {
  Color get color => switch (this) {
        SfTone.primary => SfColors.primaryLight,
        SfTone.success => SfColors.success,
        SfTone.warning => SfColors.warning,
        SfTone.danger => SfColors.danger,
        SfTone.info => SfColors.info,
        SfTone.neutral => SfColors.textSecondary,
      };
}

/// Insignia de estado real: prioridad, "Vencida", "Recién completada".
class SfBadge extends StatelessWidget {
  const SfBadge({super.key, required this.label, this.tone = SfTone.neutral});

  /// Prioridad de una actividad: alta, media o baja.
  SfBadge.priority(String priority, {super.key})
      : label = priority.isEmpty
            ? priority
            : priority[0].toUpperCase() + priority.substring(1).toLowerCase(),
        tone = switch (priority.toLowerCase()) {
          'alta' => SfTone.danger,
          'media' => SfTone.warning,
          _ => SfTone.success,
        };

  final String label;
  final SfTone tone;

  @override
  Widget build(BuildContext context) {
    final color = tone.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(SfRadius.sm),
      ),
      child: Text(
        label,
        style: SfTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
