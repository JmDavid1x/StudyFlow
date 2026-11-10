import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/domain/calculo_notas.dart';
import 'package:studyflow/features/subjects/ui/widgets/formato_materias.dart';

/// Nota actual contra la meta (Figma 22): anillo, meta, lo que falta y el
/// avance de lo evaluado.
class SubjectGradeCard extends StatelessWidget {
  const SubjectGradeCard({
    super.key,
    required this.materia,
    required this.resumen,
  });

  static const _maxGrade = 5.0;

  final Materia materia;
  final ResumenNotas resumen;

  /// Mensaje de lo que falta para la meta; nulo si no hay meta.
  String? get _mensajeFalta {
    if (materia.metaNota == null) return null;
    final falta = resumen.notaQueFalta;
    if (falta == null) return 'Ya evaluaste toda la materia';
    if (resumen.metaInalcanzable)
      return 'Tu meta ya no es alcanzable (necesitarías ${notaTexto(falta)})';
    if (falta == 0) return 'Ya aseguraste tu meta';
    final pendiente = (100 - resumen.porcentajeEvaluado).round();
    return 'Necesitas ${notaTexto(falta)} en el $pendiente % que falta';
  }

  @override
  Widget build(BuildContext context) {
    final evaluado = resumen.porcentajeEvaluado.round();
    final mensajeFalta = _mensajeFalta;

    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SfProgressRing(
                value: ((resumen.notaAcumulada ?? 0) / _maxGrade).clamp(
                  0.0,
                  1.0,
                ),
                size: SfSpacing.xxl * 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      notaTexto(resumen.notaAcumulada),
                      style: SfTypography.h1,
                    ),
                    Text('de 5.0', style: SfTypography.caption),
                  ],
                ),
              ),
              const SizedBox(width: SfSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nota acumulada · $evaluado % evaluado',
                      style: SfTypography.caption,
                    ),
                    const SizedBox(height: SfSpacing.xxs),
                    Text.rich(
                      TextSpan(
                        text: materia.metaNota == null ? 'Sin meta' : 'Meta: ',
                        style: SfTypography.h2,
                        children: [
                          if (materia.metaNota != null)
                            TextSpan(
                              text: notaTexto(materia.metaNota),
                              style: SfTypography.h2.copyWith(
                                color: SfColors.primaryLight,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (mensajeFalta != null) ...[
                      const SizedBox(height: SfSpacing.xxs),
                      Text(
                        mensajeFalta,
                        style: SfTypography.caption.copyWith(
                          color: SfColors.warningLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SfSpacing.md),
          Text(
            'Evaluado: $evaluado % de la materia',
            style: SfTypography.caption,
          ),
          const SizedBox(height: SfSpacing.xs),
          SfProgressBar(
            value: (resumen.porcentajeEvaluado / 100).clamp(0.0, 1.0),
          ),
        ],
      ),
    );
  }
}
