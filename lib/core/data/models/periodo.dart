import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/models/parse.dart';

/// Tabla `periodos`: el semestre. Solo hay uno activo por perfil.
class Periodo extends Equatable {
  const Periodo({
    required this.id,
    required this.perfilId,
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.activo,
    this.metaPromedio,
  });

  factory Periodo.fromMap(Map<String, dynamic> map) => Periodo(
        id: map['id'] as String,
        perfilId: map['perfil_id'] as String,
        nombre: map['nombre'] as String,
        fechaInicio: dia(map['fecha_inicio']),
        fechaFin: dia(map['fecha_fin']),
        metaPromedio: numeroONulo(map['meta_promedio']),
        activo: map['activo'] as bool,
      );

  final String id;
  final String perfilId;

  /// '2026-2'
  final String nombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double? metaPromedio;
  final bool activo;

  /// Para insertar (el id lo pone la base).
  Map<String, dynamic> toInsert() => {
        'perfil_id': perfilId,
        'nombre': nombre,
        'fecha_inicio': diaDb(fechaInicio),
        'fecha_fin': diaDb(fechaFin),
        'meta_promedio': metaPromedio,
        'activo': activo,
      };

  @override
  List<Object?> get props => [id, perfilId, nombre, fechaInicio, fechaFin, metaPromedio, activo];
}
