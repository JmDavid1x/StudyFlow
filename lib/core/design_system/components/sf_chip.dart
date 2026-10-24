import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_spacing.dart';
import 'package:studyflow/core/design_system/tokens/sf_typography.dart';

/// Chip de filtro: "Todas", "Hoy", "Esta semana".
class SfChip extends StatelessWidget {
  const SfChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = selected ? SfColors.textPrimary : SfColors.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? SfColors.primarySoft : SfColors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? SfColors.primary : SfColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SfSpacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 6),
                  ],
                  Text(label, style: SfTypography.bodyStrong.copyWith(color: color)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de chips con scroll horizontal, de los cuales se elige uno.
class SfChipBar<T> extends StatelessWidget {
  const SfChipBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: SfSpacing.screen),
  });

  /// Cada opción es (valor, texto).
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (final option in options) ...[
            SfChip(
              label: option.$2,
              selected: option.$1 == selected,
              onTap: () => onChanged(option.$1),
            ),
            const SizedBox(width: SfSpacing.xs),
          ],
        ],
      ),
    );
  }
}
