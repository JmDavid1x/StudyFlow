/// Reglas de nota de StudyFlow en Dart puro (sin Flutter ni Supabase).
///
/// Todas las notas van de 0.0 a 5.0 y los porcentajes de 0 a 100.
library;

import 'package:equatable/equatable.dart';

/// Una actividad ya calificada: su nota y lo que vale en la nota final.
class NotaPonderada extends Equatable {
  const NotaPonderada({required this.nota, required this.porcentaje});

  final double nota;

  /// 15.0 = 15 %.
  final double porcentaje;

  @override
  List<Object?> get props => [nota, porcentaje];
}

/// La nota acumulada de una materia y sus créditos (para el promedio del semestre).
class NotaDeMateria extends Equatable {
  const NotaDeMateria({required this.notaAcumulada, required this.creditos});

  /// Nula si la materia aún no tiene notas.
  final double? notaAcumulada;
  final int creditos;

  @override
  List<Object?> get props => [notaAcumulada, creditos];
}

/// Nota máxima posible.
const double notaMaxima = 5.0;

/// Σ porcentaje de las actividades con calificación.
double porcentajeEvaluado(Iterable<NotaPonderada> notas) =>
    notas.fold(0.0, (suma, n) => suma + n.porcentaje);

/// Σ(nota × porcentaje) ÷ Σ porcentaje. Nula si no hay nada evaluado.
double? notaAcumulada(Iterable<NotaPonderada> notas) {
  final evaluado = porcentajeEvaluado(notas);
  if (evaluado <= 0) return null;
  final ponderado = notas.fold(0.0, (suma, n) => suma + n.nota * n.porcentaje);
  return ponderado / evaluado;
}

/// Nota promedio que hay que sacar en lo que falta para llegar a [meta]:
/// (meta × 100 − Σ nota×porcentaje) ÷ (100 − % evaluado).
///
/// - Nula si no hay meta o si ya se evaluó el 100 % (no aplica).
/// - Si ya aseguraste la meta, devuelve 0 (nunca negativo).
/// - Si es mayor que 5.0, la meta es inalcanzable (ver [metaInalcanzable]).
double? notaQueFalta({
  required double? meta,
  required Iterable<NotaPonderada> notas,
}) {
  if (meta == null) return null;
  final evaluado = porcentajeEvaluado(notas);
  if (evaluado >= 100) return null;
  final ponderado = notas.fold(0.0, (suma, n) => suma + n.nota * n.porcentaje);
  final falta = (meta * 100 - ponderado) / (100 - evaluado);
  return falta < 0 ? 0.0 : falta;
}

/// La nota que falta supera el 5.0: ya no se puede llegar a la meta.
bool metaInalcanzable(double? notaQueFalta) =>
    notaQueFalta != null && notaQueFalta > notaMaxima + 1e-9;

/// Promedio de las notas acumuladas ponderado por créditos.
/// Las materias sin notas no cuentan. Nulo si ninguna tiene notas.
double? promedioSemestre(Iterable<NotaDeMateria> materias) {
  var suma = 0.0;
  var creditos = 0;
  for (final m in materias) {
    final nota = m.notaAcumulada;
    if (nota == null) continue;
    suma += nota * m.creditos;
    creditos += m.creditos;
  }
  return creditos == 0 ? null : suma / creditos;
}

/// Los componentes de una materia deben sumar 100 %.
bool componentesSuman100(Iterable<double> porcentajes) {
  final total = porcentajes.fold(0.0, (suma, p) => suma + p);
  return (total - 100).abs() < 0.001;
}

/// Nota válida para guardar: entre 0.0 y 5.0.
bool notaValida(double nota) => nota >= 0 && nota <= notaMaxima;

/// Resumen de una materia, listo para la UI.
class ResumenNotas extends Equatable {
  const ResumenNotas({
    required this.notaAcumulada,
    required this.porcentajeEvaluado,
    required this.notaQueFalta,
    required this.metaInalcanzable,
  });

  factory ResumenNotas.desde({
    required double? meta,
    required Iterable<NotaPonderada> notas,
  }) {
    final falta = _notaQueFalta(meta, notas);
    return ResumenNotas(
      notaAcumulada: _notaAcumulada(notas),
      porcentajeEvaluado: _porcentajeEvaluado(notas),
      notaQueFalta: falta,
      metaInalcanzable: _metaInalcanzable(falta),
    );
  }

  final double? notaAcumulada;
  final double porcentajeEvaluado;
  final double? notaQueFalta;
  final bool metaInalcanzable;

  @override
  List<Object?> get props => [
    notaAcumulada,
    porcentajeEvaluado,
    notaQueFalta,
    metaInalcanzable,
  ];
}

// Alias internos: dentro de ResumenNotas los campos tapan a las funciones públicas.
double? _notaAcumulada(Iterable<NotaPonderada> n) => notaAcumulada(n);
double _porcentajeEvaluado(Iterable<NotaPonderada> n) => porcentajeEvaluado(n);
double? _notaQueFalta(double? meta, Iterable<NotaPonderada> n) =>
    notaQueFalta(meta: meta, notas: n);
bool _metaInalcanzable(double? falta) => metaInalcanzable(falta);
