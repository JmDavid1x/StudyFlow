import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subscription/domain/planes_plus.dart';

/// El Plus que ya tiene el usuario: si está en prueba, cuántos días le quedan
/// y cuándo es el primer cobro. Lo muestran Perfil (25) y Plus (30) en lugar
/// de ofrecer la prueba otra vez.
class PlusActivoCard extends StatelessWidget {
  const PlusActivoCard({super.key, required this.suscripcion, this.hoy});

  final Suscripcion suscripcion;

  /// Para los tests; si es null, hoy.
  final DateTime? hoy;

  @override
  Widget build(BuildContext context) {
    final enPrueba = suscripcion.estado == EstadoSuscripcion.enPrueba;
    final hasta = suscripcion.pruebaHasta;
    final dias = diasRestantesDePrueba(suscripcion, hoy ?? DateTime.now());
    final cobro =
        '${formatoCop(suscripcion.precioCop)} ${periodoDelCobro(suscripcion.periodicidad)}';

    return SfCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'StudyFlow Plus ${nombrePlan(suscripcion.periodicidad).toLowerCase()}',
                  style: SfTypography.title,
                ),
              ),
              SfBadge(
                label: enPrueba ? 'Prueba activa' : 'Activo',
                tone: SfTone.success,
              ),
            ],
          ),
          const SizedBox(height: SfSpacing.xs),
          Text(
            'Consultas ilimitadas a la IA.',
            style: SfTypography.body.copyWith(color: SfColors.textSecondary),
          ),
          if (enPrueba && hasta != null) ...[
            const SizedBox(height: SfSpacing.sm),
            Text(textoDiasDePrueba(dias), style: SfTypography.bodyStrong),
            const SizedBox(height: SfSpacing.xxs),
            SfProgressBar(
              value:
                  (diasDePrueba - dias).clamp(0, diasDePrueba) / diasDePrueba,
              color: SfColors.success,
            ),
            const SizedBox(height: SfSpacing.xs),
            Text(
              'Hasta el ${sfFormatDate(hasta)}. Primer cobro: $cobro ese día.',
              style: SfTypography.caption.copyWith(
                color: SfColors.textSecondary,
              ),
            ),
          ] else ...[
            const SizedBox(height: SfSpacing.xs),
            Text(
              cobro,
              style: SfTypography.caption.copyWith(
                color: SfColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
