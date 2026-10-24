import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_radius.dart';
import 'package:studyflow/core/design_system/tokens/sf_typography.dart';

/// Control segmentado para 2 a 4 opciones cortas: "Mensual / Semestre",
/// "Día / Semana".
class SfSegmented<T> extends StatelessWidget {
  const SfSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  /// Cada segmento es (valor, texto).
  final List<(T, String)> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SfColors.surface,
        borderRadius: BorderRadius.circular(SfRadius.md),
        border: Border.all(color: SfColors.border),
      ),
      child: Row(
        children: [
          for (final segment in segments)
            Expanded(
              child: _Segment(
                label: segment.$2,
                selected: segment.$1 == selected,
                onTap: () => onChanged(segment.$1),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.sm);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: 40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? SfColors.primary : Colors.transparent,
              borderRadius: radius,
            ),
            child: Text(
              label,
              style: SfTypography.bodyStrong.copyWith(
                color: selected ? SfColors.textPrimary : SfColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
