import 'package:studyflow/features/subjects/domain/actividad_con_nota.dart';
import 'package:studyflow/features/subjects/domain/calculo_notas.dart';

/// Cómo quedaría el resumen de la materia si la actividad [actividadId]
/// tuviera la [nota] indicada (sirve para "Así queda tu nota acumulada").
ResumenNotas resumenConNota({
  required double? meta,
  required Iterable<ActividadConNota> actividades,
  required String actividadId,
  required double nota,
}) {
  final notas = <NotaPonderada>[];
  for (final a in actividades) {
    if (a.actividad.id == actividadId) {
      notas.add(NotaPonderada(nota: nota, porcentaje: a.actividad.porcentaje));
    } else if (a.ponderada != null) {
      notas.add(a.ponderada!);
    }
  }
  return ResumenNotas.desde(meta: meta, notas: notas);
}
