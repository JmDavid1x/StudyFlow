import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Aviso de Inicio cuando quedó un bloque de estudio sin completar
/// (Figma 12). Al tocarlo se decide qué hacer con el bloque.
class PendingBlockBanner extends StatelessWidget {
  const PendingBlockBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.lg);
    return Material(
      color: SfColors.warning.withValues(alpha: 0.1),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.all(SfSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: SfColors.warning.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: SfSpacing.lg - SfSpacing.xxs, color: SfColors.warning),
              const SizedBox(width: SfSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1 bloque de ayer sin completar', style: SfTypography.bodyStrong),
                    Text('Estudiar para Parcial 2 · toca para decidir', style: SfTypography.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: SfColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
