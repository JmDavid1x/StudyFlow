import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subjects/domain/calculo_notas.dart';

/// Una actividad de la materia con su calificación (si ya la tiene).
class ActividadConNota extends Equatable {
  const ActividadConNota({required this.actividad, this.calificacion});

  final Actividad actividad;
  final Calificacion? calificacion;

  bool get tieneNota => calificacion != null;

  /// Para las fórmulas; nula si aún no tiene nota.
  NotaPonderada? get ponderada => calificacion == null
      ? null
      : NotaPonderada(
          nota: calificacion!.nota,
          porcentaje: actividad.porcentaje,
        );

  @override
  List<Object?> get props => [actividad, calificacion];
}

extension ActividadesConNotaX on Iterable<ActividadConNota> {
  /// Solo las actividades calificadas, listas para [notaAcumulada] y compañía.
  List<NotaPonderada> get ponderadas =>
      map((a) => a.ponderada).whereType<NotaPonderada>().toList();
}
