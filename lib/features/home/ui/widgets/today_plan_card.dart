import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// "Tu plan de hoy": lo que sugiere el asistente para el día (Figma 12 y 16).
/// Es la tarjeta destacada de Inicio y lleva su acción principal.
class TodayPlanCard extends StatelessWidget {
  const TodayPlanCard({super.key, required this.plan, required this.onTalk});

  final String plan;
  final VoidCallback onTalk;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: SfSpacing.xl + SfSpacing.xxs,
                height: SfSpacing.xl + SfSpacing.xxs,
                decoration: BoxDecoration(
                  color: SfColors.primary,
                  borderRadius: BorderRadius.circular(SfRadius.md),
                ),
                child: const Icon(Icons.smart_toy_outlined, size: SfSpacing.lg - SfSpacing.xxs, color: SfColors.textPrimary),
              ),
              const SizedBox(width: SfSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tu plan de hoy', style: SfTypography.title),
                    Text('Asistente académico', style: SfTypography.caption.copyWith(color: SfColors.primaryLight)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SfSpacing.sm),
          Text(plan, style: SfTypography.body),
          const SizedBox(height: SfSpacing.md),
          SfButton(label: 'Hablar con el asistente', onPressed: onTalk),
        ],
      ),
    );
  }
}
