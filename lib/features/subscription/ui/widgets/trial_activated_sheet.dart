import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/subscription/ui/widgets/subscription_demo.dart';

/// S11 Prueba activada. Al continuar saca Plus y Pago de la pila y abre el
/// Asistente, para que "atrás" no vuelva al pago.
Future<void> showTrialActivatedSheet(BuildContext context, PlusPlan plan) {
  return showSfBottomSheet<void>(
    context,
    builder: (sheetContext) => SfResultSheet(
      icon: Icons.auto_awesome_rounded,
      tone: SfTone.primary,
      title: 'Prueba activada',
      message: 'Tienes StudyFlow Plus gratis hasta el ${sfFormatDate(SubscriptionDemo.trialEnd)}. '
          'Ya puedes preguntarle al asistente sin límite.',
      primaryLabel: 'Ir al asistente',
      onPrimary: () {
        const flow = {AppRoutes.plus, AppRoutes.payment, AppRoutes.assistant};
        Navigator.pop(sheetContext);
        Navigator.popUntil(context, (route) => route.isFirst || !flow.contains(route.settings.name));
        Navigator.pushNamed(context, AppRoutes.assistant);
      },
      child: SfCard(
        child: Row(
          children: [
            Expanded(child: Text('Plan ${plan.label.toLowerCase()}', style: SfTypography.bodyStrong)),
            Text('${plan.price} ${plan.period}', style: SfTypography.number),
          ],
        ),
      ),
    ),
  );
}
