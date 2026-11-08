import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/models/parse.dart';

/// Tabla `calificaciones`: la nota de una actividad (una por actividad).
class Calificacion extends Equatable {
  const Calificacion({
    required this.id,
    required this.actividadId,
    required this.nota,
    required this.registradaEn,
  });

  factory Calificacion.fromMap(Map<String, dynamic> map) => Calificacion(
        id: map['id'] as String,
        actividadId: map['actividad_id'] as String,
        nota: numero(map['nota']),
        registradaEn: fecha(map['registrada_en']),
      );

  final String id;
  final String actividadId;

  /// Entre 0.0 y 5.0.
  final double nota;
  final DateTime registradaEn;

  @override
  List<Object?> get props => [id, actividadId, nota, registradaEn];
}
