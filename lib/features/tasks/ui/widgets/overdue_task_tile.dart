import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';

/// Fila de una tarea vencida (Figma 17, sección Vencidas). En rojo y sin
/// círculo para completar: primero hay que decir si se entregó.
class OverdueTaskTile extends StatelessWidget {
  const OverdueTaskTile({super.key, required this.task, this.onTap});

  final DemoTask task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.lg);
    return Material(
      color: SfColors.danger.withValues(alpha: 0.08),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.all(SfSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: SfColors.danger.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Container(
                width: SfSpacing.xl,
                height: SfSpacing.xl,
                decoration: BoxDecoration(
                  color: SfColors.danger.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, size: SfSpacing.md, color: SfColors.danger),
              ),
              const SizedBox(width: SfSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: SfTypography.bodyStrong),
                    Text('${task.subject} · ${task.due}', style: SfTypography.caption),
                  ],
                ),
              ),
              const SizedBox(width: SfSpacing.xs),
              const Flexible(child: SfBadge(label: '¿La entregaste?', tone: SfTone.danger)),
            ],
          ),
        ),
      ),
    );
  }
}
