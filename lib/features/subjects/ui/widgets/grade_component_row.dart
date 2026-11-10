import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/domain/resumen_semestre.dart';
import 'package:studyflow/features/subjects/ui/widgets/formato_materias.dart';

/// Fila de "Cómo se calcula tu nota" (Figma 22): componente, porcentaje y
/// resultado ("4.3", "Sin nota" o "3.8 · 2 de 3").
class GradeComponentRow extends StatelessWidget {
  const GradeComponentRow({super.key, required this.resumen});

  final ResumenComponente resumen;

  String get _resultado {
    final nota = resumen.nota;
    if (nota == null) return 'Sin nota';
    if (resumen.calificadas == resumen.total) return notaTexto(nota);
    return '${notaTexto(nota)} · ${resumen.calificadas} de ${resumen.total}';
  }

  @override
  Widget build(BuildContext context) {
    final componente = resumen.componente;
    final porcentaje = componente.porcentaje;
    final porcentajeTexto = porcentaje == porcentaje.roundToDouble()
        ? porcentaje.round().toString()
        : porcentaje.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: SfSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SfColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${componente.nombre} · $porcentajeTexto %',
              style: SfTypography.body.copyWith(color: SfColors.textSecondary),
            ),
          ),
          Text(_resultado, style: SfTypography.bodyStrong),
        ],
      ),
    );
  }
}
