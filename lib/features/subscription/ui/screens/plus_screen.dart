import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/assistant/ui/widgets/assistant_demo.dart';
import 'package:studyflow/features/subscription/ui/widgets/plan_comparison_table.dart';
import 'package:studyflow/features/subscription/ui/widgets/subscription_demo.dart';

/// StudyFlow Plus (Figma 30). Compara los planes y deja elegir Mensual o
/// Semestre antes de ir al pago.
class PlusScreen extends StatefulWidget {
  const PlusScreen({super.key});

  @override
  State<PlusScreen> createState() => _PlusScreenState();
}

class _PlusScreenState extends State<PlusScreen> {
  var _plan = PlusPlan.monthly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'StudyFlow Plus'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Pregúntale al asistente sin límite', style: SfTypography.h1),
                    const SizedBox(height: SfSpacing.xs),
                    Text(
                      'Con Plus tienes consultas ilimitadas para ordenar tus tareas y armar tu plan de estudio.',
                      style: SfTypography.body.copyWith(color: SfColors.textSecondary),
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    const PlanComparisonTable(features: SubscriptionDemo.features),
                    const SizedBox(height: SfSpacing.lg),
                    const _FreeUsageCard(),
                    const SizedBox(height: SfSpacing.lg),
                    Text('Elige tu plan', style: SfTypography.h2),
                    const SizedBox(height: SfSpacing.sm),
                    SfSegmented<PlusPlan>(
                      segments: [for (final plan in PlusPlan.values) (plan, plan.label)],
                      selected: _plan,
                      onChanged: (plan) => setState(() => _plan = plan),
                    ),
                    const SizedBox(height: SfSpacing.md),
                    Text(
                      '${_plan.price} ${_plan.period}',
                      textAlign: TextAlign.center,
                      style: SfTypography.h2,
                    ),
                    const SizedBox(height: SfSpacing.xxs),
                    Text(
                      'Los primeros ${SubscriptionDemo.trialDays} días son gratis. Cancela cuando quieras.',
                      textAlign: TextAlign.center,
                      style: SfTypography.caption.copyWith(color: SfColors.textSecondary),
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    SfButton(
                      label: 'Probar ${SubscriptionDemo.trialDays} días gratis',
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.payment, arguments: _plan),
                    ),
                    const SizedBox(height: SfSpacing.xxs),
                    SfButton(
                      label: 'Seguir con el plan gratis',
                      variant: SfButtonVariant.ghost,
                      onPressed: () => Navigator.pop(context),
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

/// Consultas gratis usadas esta semana, con los mismos números del Asistente.
class _FreeUsageCard extends StatelessWidget {
  const _FreeUsageCard();

  @override
  Widget build(BuildContext context) {
    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Consultas gratis esta semana', style: SfTypography.bodyStrong)),
              Text(
                '${AssistantDemo.freeUsed} de ${AssistantDemo.freeLimit}',
                style: SfTypography.number.copyWith(color: SfColors.primaryLight),
              ),
            ],
          ),
          const SizedBox(height: SfSpacing.sm),
          const SfProgressBar(value: AssistantDemo.freeUsed / AssistantDemo.freeLimit),
        ],
      ),
    );
  }
}
