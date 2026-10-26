import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/assistant/ui/widgets/suggested_order_card.dart';

/// Figma 31: la IA no respondió. Muestra el orden de respaldo (por prioridad)
/// y aclara que esta respuesta no gasta consultas gratis. Los botones solo
/// se muestran si es el último mensaje del chat.
class OfflineNotice extends StatelessWidget {
  const OfflineNotice({
    super.key,
    required this.fallback,
    this.onRetry,
    this.onAddToCalendar,
  });

  final List<DemoTask> fallback;
  final VoidCallback? onRetry;
  final VoidCallback? onAddToCalendar;

  @override
  Widget build(BuildContext context) {
    final showActions = onRetry != null && onAddToCalendar != null;
    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: SfTone.warning.color),
              const SizedBox(width: SfSpacing.xs),
              Expanded(child: Text('El asistente no respondió', style: SfTypography.title)),
            ],
          ),
          const SizedBox(height: SfSpacing.xxs),
          Text(
            'Revisa tu conexión. Mientras tanto, este es un orden de respaldo según la prioridad de cada actividad.',
            style: SfTypography.body.copyWith(color: SfColors.textSecondary),
          ),
          const SizedBox(height: SfSpacing.sm),
          if (fallback.isEmpty)
            const SfEmptyState(
              icon: Icons.event_available_outlined,
              title: 'No tienes actividades pendientes',
              message: 'Agrega una tarea para armar tu orden de estudio.',
            )
          else
            for (final (index, task) in fallback.indexed)
              NumberedTaskRow(
                number: index + 1,
                title: task.title,
                subtitle: '${task.subject} · ${task.due}',
                color: task.color,
              ),
          const SfBadge(label: 'Esta respuesta no gasta tus consultas gratis', tone: SfTone.success),
          if (showActions) ...[
            const SizedBox(height: SfSpacing.md),
            SfButton(
              label: 'Agregar este orden al calendario',
              icon: Icons.calendar_month_outlined,
              onPressed: fallback.isEmpty ? null : onAddToCalendar,
            ),
            const SizedBox(height: SfSpacing.xs),
            SfButton(
              label: 'Reintentar',
              icon: Icons.refresh_rounded,
              variant: SfButtonVariant.secondary,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
