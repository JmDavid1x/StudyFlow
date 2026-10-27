import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/ui/widgets/subjects_prototype_data.dart';

/// Elige a qué componente de la nota pertenece una actividad (Figma 23):
/// tres tarjetas angostas con el porcentaje y el nombre.
class ComponentSelector extends StatelessWidget {
  const ComponentSelector({
    super.key,
    required this.components,
    required this.selected,
    required this.onChanged,
  });

  final List<PrototypeComponent> components;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < components.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : SfSpacing.sm),
              child: _ComponentCard(
                component: components[i],
                selected: i == selected,
                onTap: () => onChanged(i),
              ),
            ),
          ),
      ],
    );
  }
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({
    required this.component,
    required this.selected,
    required this.onTap,
  });

  final PrototypeComponent component;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.md);
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
            padding: const EdgeInsets.all(SfSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? SfColors.primary : SfColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${component.percent} %',
                          style: SfTypography.h2.copyWith(color: SfColors.primaryLight),
                        ),
                      ),
                    ),
                    SfRadioDot(selected: selected),
                  ],
                ),
                const SizedBox(height: SfSpacing.xxs),
                Text(
                  component.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SfTypography.caption.copyWith(color: SfColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
