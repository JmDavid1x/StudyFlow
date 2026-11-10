import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/assistant/domain/limite_consultas.dart';
import 'package:studyflow/features/subscription/domain/planes_plus.dart';
import 'package:studyflow/features/subscription/ui/bloc/plus_cubit.dart';
import 'package:studyflow/features/subscription/ui/widgets/plan_comparison_table.dart';
import 'package:studyflow/features/subscription/ui/widgets/plan_texts.dart';

/// StudyFlow Plus (Figma 30). Compara los planes y deja elegir Mensual o
/// Semestre antes de ir al pago. El Cubit se crea en subscription_routes.dart.
class PlusScreen extends StatelessWidget {
  const PlusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'StudyFlow Plus'),
            Expanded(
              child: BlocBuilder<PlusCubit, PlusState>(
                builder: (context, state) {
                  switch (state.estado) {
                    case EstadoPlus.cargando:
                      return const Center(
                        child: SfLoadingState(message: 'Cargando tu plan'),
                      );
                    case EstadoPlus.error:
                      return Center(
                        child: SingleChildScrollView(
                          child: SfErrorState(
                            message:
                                state.mensaje ?? 'No pudimos cargar tu plan.',
                            onRetry: () => context.read<PlusCubit>().cargar(),
                          ),
                        ),
                      );
                    case EstadoPlus.listo:
                      return _PlusContent(state: state);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlusContent extends StatelessWidget {
  const _PlusContent({required this.state});

  final PlusState state;

  /// Va al pago con la periodicidad elegida; si inició la prueba, Plus ya no
  /// sigue en la pila (S11 lleva al asistente), así que al volver se recarga.
  Future<void> _irAlPago(BuildContext context) async {
    final cubit = context.read<PlusCubit>();
    await Navigator.pushNamed(
      context,
      AppRoutes.payment,
      arguments: state.periodicidad,
    );
    if (context.mounted) await cubit.cargar();
  }

  @override
  Widget build(BuildContext context) {
    final periodicidad = state.periodicidad;
    final pruebaHasta = state.suscripcion?.pruebaHasta;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SfSpacing.screen,
        SfSpacing.xs,
        SfSpacing.screen,
        SfSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pregúntale al asistente sin límite', style: SfTypography.h1),
          const SizedBox(height: SfSpacing.xs),
          Text(
            'Con Plus tienes consultas ilimitadas a la IA para ordenar tus tareas y armar tu plan de estudio.',
            style: SfTypography.body.copyWith(color: SfColors.textSecondary),
          ),
          const SizedBox(height: SfSpacing.lg),
          const PlanComparisonTable(features: planFeatures),
          const SizedBox(height: SfSpacing.lg),
          _UsageCard(limite: state.limite),
          const SizedBox(height: SfSpacing.lg),
          if (state.esPlus) ...[
            SfCard(
              highlighted: true,
              child: Text(
                pruebaHasta == null
                    ? 'Ya tienes StudyFlow Plus.'
                    : 'Ya tienes StudyFlow Plus. Tu prueba gratis va hasta el ${sfFormatDate(pruebaHasta)}.',
                style: SfTypography.bodyStrong,
              ),
            ),
            const SizedBox(height: SfSpacing.lg),
            SfButton(
              label: 'Volver',
              variant: SfButtonVariant.secondary,
              onPressed: () => Navigator.pop(context),
            ),
          ] else ...[
            Text('Elige tu plan', style: SfTypography.h2),
            const SizedBox(height: SfSpacing.sm),
            SfSegmented<Periodicidad>(
              segments: [
                for (final opcion in Periodicidad.values)
                  (opcion, nombrePlan(opcion)),
              ],
              selected: periodicidad,
              onChanged: context.read<PlusCubit>().elegir,
            ),
            const SizedBox(height: SfSpacing.md),
            Text(
              '${formatoCop(precioPlus(periodicidad))} ${periodoDelCobro(periodicidad)}',
              textAlign: TextAlign.center,
              style: SfTypography.h2,
            ),
            const SizedBox(height: SfSpacing.xxs),
            Text(
              'Los primeros $diasDePrueba días son gratis. Cancela cuando quieras.',
              textAlign: TextAlign.center,
              style: SfTypography.caption.copyWith(
                color: SfColors.textSecondary,
              ),
            ),
            const SizedBox(height: SfSpacing.lg),
            SfButton(
              label: 'Probar $diasDePrueba días gratis',
              onPressed: () => _irAlPago(context),
            ),
            const SizedBox(height: SfSpacing.xxs),
            SfButton(
              label: 'Seguir con el plan gratis',
              variant: SfButtonVariant.ghost,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }
}

/// Consultas gratis usadas esta semana (o "ilimitadas" si ya es Plus).
class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.limite});

  final LimiteConsultas limite;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Consultas gratis esta semana',
                  style: SfTypography.bodyStrong,
                ),
              ),
              Text(
                limite.esPlus
                    ? 'Ilimitadas'
                    : '${limite.usadas} de $consultasGratisPorSemana',
                style: SfTypography.number.copyWith(
                  color: SfColors.primaryLight,
                ),
              ),
            ],
          ),
          if (!limite.esPlus) ...[
            const SizedBox(height: SfSpacing.sm),
            SfProgressBar(value: limite.progreso),
          ],
        ],
      ),
    );
  }
}
