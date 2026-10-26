import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subscription/ui/widgets/subscription_demo.dart';
import 'package:studyflow/features/subscription/ui/widgets/trial_activated_sheet.dart';

/// Pago (Figma 32). Resumen de la prueba y método de pago. No pide datos de
/// tarjeta: eso lo hace la pasarela en el Sprint 2.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  var _method = PaymentMethod.card;

  @override
  Widget build(BuildContext context) {
    // El plan llega desde StudyFlow Plus; si se abre directo, Mensual.
    final argument = ModalRoute.of(context)?.settings.arguments;
    final plan = argument is PlusPlan ? argument : PlusPlan.monthly;
    final trialEnd = sfFormatDate(SubscriptionDemo.trialEnd);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Pago', useCloseIcon: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Resumen', style: SfTypography.h2),
                    const SizedBox(height: SfSpacing.sm),
                    SfCard(
                      highlighted: true,
                      child: Column(
                        children: [
                          _SummaryRow(label: 'StudyFlow Plus ${plan.label.toLowerCase()}', value: plan.price),
                          const SizedBox(height: SfSpacing.sm),
                          _SummaryRow(label: 'Fin de la prueba', value: trialEnd),
                          const SizedBox(height: SfSpacing.sm),
                          _SummaryRow(label: 'Primer cobro', value: '${plan.price}, $trialEnd'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: SfSpacing.sm),
                            child: Divider(height: 1, color: SfColors.border),
                          ),
                          const _SummaryRow(label: 'Hoy pagas', value: 'COP 0', strong: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    Text('Método de pago', style: SfTypography.h2),
                    const SizedBox(height: SfSpacing.sm),
                    SfOptionCards<PaymentMethod>(
                      columns: 1,
                      selected: _method,
                      onChanged: (method) => setState(() => _method = method),
                      options: [
                        for (final method in PaymentMethod.values)
                          SfOption(
                            value: method,
                            label: method.label,
                            subtitle: method.subtitle,
                            icon: method.icon,
                          ),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: SfSpacing.md + SfSpacing.xxs, color: SfColors.textSecondary),
                        const SizedBox(width: SfSpacing.xs),
                        Expanded(
                          child: Text(
                            'El pago lo procesa la pasarela. StudyFlow no guarda los datos de tu tarjeta.',
                            style: SfTypography.caption.copyWith(color: SfColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    SfButton(
                      label: 'Iniciar prueba gratis',
                      onPressed: () => showTrialActivatedSheet(context, plan),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: strong ? SfTypography.bodyStrong : SfTypography.body.copyWith(color: SfColors.textSecondary),
          ),
        ),
        Text(value, style: strong ? SfTypography.title : SfTypography.number),
      ],
    );
  }
}
