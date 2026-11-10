import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/assistant/domain/orden_respaldo.dart';
import 'package:studyflow/features/assistant/ui/widgets/suggested_order_card.dart';

/// Figma 31: la IA no respondió. Muestra el orden de respaldo y aclara que
/// esta respuesta no gasta consultas gratis.
class OfflineNotice extends StatelessWidget {
  const OfflineNotice({
    super.key,
    required this.orden,
    required this.onRetry,
    required this.onAddToCalendar,
    this.ocupado = false,
  });

  final List<ItemOrden> orden;
  final VoidCallback onRetry;
  final VoidCallback onAddToCalendar;

  /// Reintentando o creando el plan: los botones esperan.
  final bool ocupado;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: SfTone.warning.color),
              const SizedBox(width: SfSpacing.xs),
              Expanded(
                child: Text(
                  'El asistente no respondió',
                  style: SfTypography.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: SfSpacing.xxs),
          Text(
            'Mientras tanto, este es un orden de respaldo: lo que vence primero, lo que vale más y la prioridad de cada actividad.',
            style: SfTypography.body.copyWith(color: SfColors.textSecondary),
          ),
          const SizedBox(height: SfSpacing.sm),
          OrderList(orden: orden),
          const Align(
            alignment: Alignment.centerLeft,
            child: SfBadge(
              label: 'Esta respuesta no gasta tus consultas gratis',
              tone: SfTone.success,
            ),
          ),
          const SizedBox(height: SfSpacing.md),
          SfButton(
            label: 'Agregar este orden al calendario',
            icon: Icons.calendar_month_outlined,
            onPressed: orden.isEmpty || ocupado ? null : onAddToCalendar,
          ),
          const SizedBox(height: SfSpacing.xs),
          SfButton(
            label: 'Reintentar',
            icon: Icons.refresh_rounded,
            variant: SfButtonVariant.secondary,
            onPressed: ocupado ? null : onRetry,
          ),
        ],
      ),
    );
  }
}
