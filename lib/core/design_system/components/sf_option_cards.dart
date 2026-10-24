import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_radius.dart';
import 'package:studyflow/core/design_system/tokens/sf_spacing.dart';
import 'package:studyflow/core/design_system/tokens/sf_typography.dart';

/// Una opción para [SfOptionCards].
class SfOption<T> {
  const SfOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.color,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  /// Color del ícono (por ejemplo, el color de una materia).
  final Color? color;
}

/// Selector de tarjetas: reemplaza a los desplegables. Todas las opciones
/// están a la vista y se elige una con un toque (tipo de actividad, materia,
/// canal de entrega, método de pago).
class SfOptionCards<T> extends StatelessWidget {
  const SfOptionCards({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.columns = 2,
  });

  final List<SfOption<T>> options;
  final T? selected;
  final ValueChanged<T> onChanged;

  /// 1 para listas (métodos de pago), 2 o 3 para opciones cortas.
  final int columns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = SfSpacing.sm;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final option in options)
              SizedBox(
                width: width,
                child: _OptionCard<T>(
                  option: option,
                  selected: option.value == selected,
                  onTap: () => onChanged(option.value),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OptionCard<T> extends StatelessWidget {
  const _OptionCard({required this.option, required this.selected, required this.onTap});

  final SfOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.md);
    final iconColor = option.color ?? SfColors.primaryLight;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? SfColors.primarySoft : SfColors.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? SfColors.primary : SfColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                if (option.icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(option.icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: SfSpacing.sm - 2),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.label, style: SfTypography.bodyStrong),
                      if (option.subtitle != null)
                        Text(option.subtitle!, style: SfTypography.caption),
                    ],
                  ),
                ),
                const SizedBox(width: SfSpacing.xs),
                SfRadioDot(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Círculo de selección única.
class SfRadioDot extends StatelessWidget {
  const SfRadioDot({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? SfColors.primary : SfColors.borderStrong,
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: SfColors.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
