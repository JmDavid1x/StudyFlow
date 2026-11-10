import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subscription/domain/planes_plus.dart';
import 'package:studyflow/features/subscription/ui/bloc/payment_cubit.dart';
import 'package:studyflow/features/subscription/ui/widgets/plan_texts.dart';
import 'package:studyflow/features/subscription/ui/widgets/trial_activated_sheet.dart';

/// Pago (Figma 32). Resumen de la prueba y método de pago. No pide datos de
/// tarjeta: eso lo hace la pasarela. El Cubit se crea en subscription_routes.dart.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listenWhen: (antes, ahora) =>
          antes.errorId != ahora.errorId ||
          (ahora.estado == EtapaPago.activada &&
              antes.estado != EtapaPago.activada),
      listener: (context, state) {
        if (state.estado == EtapaPago.activada) {
          showTrialActivatedSheet(context, state.suscripcion!);
        } else if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<PaymentCubit>();
        final periodicidad = state.periodicidad;
        final precio = formatoCop(precioPlus(periodicidad));
        final finPrueba = sfFormatDate(finDePrueba(DateTime.now()));
        final enviando = state.estado == EtapaPago.enviando;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SfScreenHeader(title: 'Pago', useCloseIcon: true),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      SfSpacing.screen,
                      SfSpacing.xs,
                      SfSpacing.screen,
                      SfSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Resumen', style: SfTypography.h2),
                        const SizedBox(height: SfSpacing.sm),
                        SfCard(
                          highlighted: true,
                          child: Column(
                            children: [
                              _SummaryRow(
                                label:
                                    'StudyFlow Plus ${nombrePlan(periodicidad).toLowerCase()}',
                                value: precio,
                              ),
                              const SizedBox(height: SfSpacing.sm),
                              _SummaryRow(
                                label: 'Fin de la prueba',
                                value: finPrueba,
                              ),
                              const SizedBox(height: SfSpacing.sm),
                              _SummaryRow(
                                label: 'Primer cobro',
                                value: '$precio, $finPrueba',
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: SfSpacing.sm,
                                ),
                                child: Divider(
                                  height: 1,
                                  color: SfColors.border,
                                ),
                              ),
                              _SummaryRow(
                                label: 'Hoy pagas',
                                value: formatoCop(0),
                                strong: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: SfSpacing.lg),
                        Text('Método de pago', style: SfTypography.h2),
                        const SizedBox(height: SfSpacing.sm),
                        SfOptionCards<MetodoPago>(
                          columns: 1,
                          selected: state.metodo,
                          onChanged: cubit.elegirMetodo,
                          options: [
                            for (final metodo in MetodoPago.values)
                              SfOption(
                                value: metodo,
                                label: textosMetodo(metodo).label,
                                subtitle: textosMetodo(metodo).subtitle,
                                icon: textosMetodo(metodo).icon,
                              ),
                          ],
                        ),
                        const SizedBox(height: SfSpacing.md),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: SfSpacing.md + SfSpacing.xxs,
                              color: SfColors.textSecondary,
                            ),
                            const SizedBox(width: SfSpacing.xs),
                            Expanded(
                              child: Text(
                                'El pago lo procesa la pasarela. StudyFlow no guarda los datos de tu tarjeta.',
                                style: SfTypography.caption.copyWith(
                                  color: SfColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: SfSpacing.lg),
                        SfButton(
                          label: 'Iniciar prueba gratis',
                          isLoading: enviando,
                          onPressed: state.estado == EtapaPago.eligiendo
                              ? cubit.iniciarPrueba
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

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
            style: strong
                ? SfTypography.bodyStrong
                : SfTypography.body.copyWith(color: SfColors.textSecondary),
          ),
        ),
        Text(value, style: strong ? SfTypography.title : SfTypography.number),
      ],
    );
  }
}
