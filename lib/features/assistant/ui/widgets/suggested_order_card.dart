import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/assistant/domain/orden_respaldo.dart';

/// Tarjeta "Este es tu orden sugerido" con las actividades numeradas (Figma 24).
class SuggestedOrderCard extends StatelessWidget {
  const SuggestedOrderCard({
    super.key,
    required this.orden,
    this.onAddToCalendar,
    this.agregando = false,
  });

  final List<ItemOrden> orden;
  final VoidCallback? onAddToCalendar;
  final bool agregando;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Este es tu orden sugerido', style: SfTypography.title),
          const SizedBox(height: SfSpacing.sm),
          OrderList(orden: orden),
          if (onAddToCalendar != null && orden.isNotEmpty) ...[
            const SizedBox(height: SfSpacing.xs),
            SfButton(
              label: 'Agregar plan al calendario',
              icon: Icons.calendar_month_outlined,
              isLoading: agregando,
              onPressed: agregando ? null : onAddToCalendar,
            ),
          ],
        ],
      ),
    );
  }
}

/// Las actividades numeradas, o el estado vacío si no hay pendientes.
class OrderList extends StatelessWidget {
  const OrderList({super.key, required this.orden});

  final List<ItemOrden> orden;

  @override
  Widget build(BuildContext context) {
    if (orden.isEmpty) {
      return const SfEmptyState(
        icon: Icons.event_available_outlined,
        title: 'No tienes actividades pendientes',
        message: 'Agrega una tarea y pídeme de nuevo tu orden sugerido.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final item in orden) NumberedTaskRow(item: item)],
    );
  }
}

/// Fila con el número de la actividad en un círculo del color de su materia.
class NumberedTaskRow extends StatelessWidget {
  const NumberedTaskRow({super.key, required this.item});

  final ItemOrden item;

  @override
  Widget build(BuildContext context) {
    final actividad = item.actividad;
    final color = actividad.materiaColor ?? SfColors.primaryLight;
    final subtitulo = [
      if (actividad.materiaNombre != null) actividad.materiaNombre!,
      item.motivo,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: SfSpacing.sm),
      child: Row(
        children: [
          Container(
            width: SfSpacing.xl,
            height: SfSpacing.xl,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${item.orden}',
              style: SfTypography.number.copyWith(color: color),
            ),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(actividad.titulo, style: SfTypography.bodyStrong),
                Text(
                  subtitulo,
                  style: SfTypography.caption.copyWith(
                    color: SfColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
