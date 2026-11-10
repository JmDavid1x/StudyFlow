import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/subscription/domain/planes_plus.dart';

/// S11 Prueba activada. Al continuar saca Plus y Pago de la pila y abre el
/// Asistente, para que "atrás" no vuelva al pago.
Future<void> showTrialActivatedSheet(
  BuildContext context,
  Suscripcion suscripcion,
) {
  final hasta = suscripcion.pruebaHasta;
  return showSfBottomSheet<void>(
    context,
    builder: (sheetContext) => SfResultSheet(
      icon: Icons.auto_awesome_rounded,
      tone: SfTone.primary,
      title: 'Prueba activada',
      message:
          '${hasta == null ? 'Ya tienes StudyFlow Plus.' : 'Tienes StudyFlow Plus gratis hasta el ${sfFormatDate(hasta)}.'} '
          'Ya puedes preguntarle al asistente sin límite.',
      primaryLabel: 'Ir al asistente',
      onPrimary: () {
        const flujo = {AppRoutes.plus, AppRoutes.payment, AppRoutes.assistant};
        Navigator.pop(sheetContext);
        Navigator.popUntil(
          context,
          (route) => route.isFirst || !flujo.contains(route.settings.name),
        );
        Navigator.pushNamed(context, AppRoutes.assistant);
      },
      child: SfCard(
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Plan ${nombrePlan(suscripcion.periodicidad).toLowerCase()}',
                style: SfTypography.bodyStrong,
              ),
            ),
            Text(
              '${formatoCop(suscripcion.precioCop)} ${periodoDelCobro(suscripcion.periodicidad)}',
              style: SfTypography.number,
            ),
          ],
        ),
      ),
    ),
  );
}
