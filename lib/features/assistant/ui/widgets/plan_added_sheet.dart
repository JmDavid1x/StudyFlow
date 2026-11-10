import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/assistant/domain/usecases/agregar_al_plan.dart';
import 'package:studyflow/features/assistant/ui/widgets/suggested_order_card.dart';

/// S4 Plan agregado: las actividades en el orden del plan y, debajo de cada
/// una, los bloques de estudio que se agendaron con su día y hora.
Future<void> showPlanAddedSheet(BuildContext context, PlanAgregado agregado) {
  final sinBloques = agregado.bloques.isEmpty;
  return showSfBottomSheet<void>(
    context,
    builder: (sheetContext) => SfResultSheet(
      title: 'Plan agregado',
      message: sinBloques
          ? 'Guardamos tu orden, pero no encontramos espacio libre antes de las fechas límite.'
          : 'Tus bloques de estudio ya están en el calendario, en este orden.',
      primaryLabel: 'Ver calendario',
      onPrimary: () => Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (_) => false,
        arguments: AppTabs.calendar,
      ),
      secondaryLabel: 'Volver al chat',
      onSecondary: () => Navigator.pop(sheetContext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in agregado.orden) ...[
            NumberedTaskRow(item: item),
            for (final bloque in agregado.bloques.where(
              (b) => b.actividadId == item.actividad.id,
            ))
              Padding(
                padding: const EdgeInsets.only(
                  left: SfSpacing.xxl,
                  bottom: SfSpacing.xs,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: SfSpacing.md,
                      color: SfColors.info,
                    ),
                    const SizedBox(width: SfSpacing.xs),
                    Expanded(
                      child: Text(
                        '${sfFormatDate(bloque.inicio)} · ${sfFormatTime(TimeOfDay.fromDateTime(bloque.inicio))} a ${sfFormatTime(TimeOfDay.fromDateTime(bloque.fin))}',
                        style: SfTypography.caption.copyWith(
                          color: SfColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: SfSpacing.xs),
          ],
        ],
      ),
    ),
  );
}
