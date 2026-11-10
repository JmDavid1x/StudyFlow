import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subjects/domain/actividad_con_nota.dart';
import 'package:studyflow/features/subjects/domain/calculo_notas.dart';

/// Una materia con sus notas ya calculadas.
class MateriaConNota extends Equatable {
  const MateriaConNota({required this.materia, required this.resumen});

  final Materia materia;
  final ResumenNotas resumen;

  @override
  List<Object?> get props => [materia, resumen];
}

/// Todas las materias del periodo y el promedio del semestre.
class ResumenSemestre extends Equatable {
  const ResumenSemestre({required this.materias, required this.promedio});

  final List<MateriaConNota> materias;

  /// Ponderado por créditos. Nulo si ninguna materia tiene notas.
  final double? promedio;

  bool get vacio => materias.isEmpty;

  @override
  List<Object?> get props => [materias, promedio];
}

/// Resultado de un componente de la nota (Talleres · 30 %).
class ResumenComponente extends Equatable {
  const ResumenComponente({
    required this.componente,
    required this.nota,
    required this.calificadas,
    required this.total,
  });

  final ComponenteNota componente;

  /// Promedio de las actividades calificadas del componente; nulo si ninguna.
  final double? nota;
  final int calificadas;
  final int total;

  @override
  List<Object?> get props => [componente, nota, calificadas, total];
}

/// Resultado de cada componente de la materia, en el orden de [componentes].
List<ResumenComponente> resumenDeComponentes(
  List<ComponenteNota> componentes,
  List<ActividadConNota> actividades,
) {
  return [
    for (final componente in componentes)
      () {
        final propias = actividades
            .where((a) => a.actividad.componenteId == componente.id)
            .toList();
        final notas = propias
            .where((a) => a.tieneNota)
            .map((a) => a.calificacion!.nota)
            .toList();
        final promedio = notas.isEmpty
            ? null
            : notas.reduce((a, b) => a + b) / notas.length;
        return ResumenComponente(
          componente: componente,
          nota: promedio,
          calificadas: notas.length,
          total: propias.length,
        );
      }(),
  ];
}
