import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Tarjeta de un tipo de aviso: título, ayuda e interruptor. Si está
/// encendido, muestra debajo los selectores de cuándo avisar ([children]).
class NotificationSettingCard extends StatelessWidget {
  const NotificationSettingCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onChanged,
    this.children = const [],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MergeSemantics(
            child: Row(
              children: [
                Icon(icon, color: enabled ? SfColors.primaryLight : SfColors.textSecondary),
                const SizedBox(width: SfSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: SfTypography.bodyStrong),
                      Text(subtitle, style: SfTypography.caption.copyWith(color: SfColors.textSecondary)),
                    ],
                  ),
                ),
                Switch(value: enabled, onChanged: onChanged),
              ],
            ),
          ),
          if (enabled && children.isNotEmpty) ...[
            const SizedBox(height: SfSpacing.md),
            for (final (index, child) in children.indexed) ...[
              if (index > 0) const SizedBox(height: SfSpacing.sm),
              child,
            ],
          ],
        ],
      ),
    );
  }
}
