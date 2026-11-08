import 'dart:ui' show Color;

import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/models/enums.dart';
import 'package:studyflow/core/data/models/materia.dart';
import 'package:studyflow/core/data/models/parse.dart';

/// Tabla `bloques_estudio`: tiempo reservado para preparar una actividad.
/// [planId] nulo = lo creó el usuario; con plan = lo creó el asistente.
class BloqueEstudio extends Equatable {
  const BloqueEstudio({
    required this.id,
    required this.actividadId,
    required this.inicio,
    required this.fin,
    required this.estado,
    this.planId,
    this.avisoMin,
    this.completadoEn,
    this.actividadTitulo,
    this.materiaNombre,
    this.materiaColorHex,
  });

  /// Select con el título de la actividad y su materia.
  static const select =
      '*, actividades(titulo, componentes_nota(materias(nombre, color)))';

  factory BloqueEstudio.fromMap(Map<String, dynamic> map) {
    final actividad = anidado(map['actividades']);
    final materia = anidado(anidado(actividad?['componentes_nota'])?['materias']);
    return BloqueEstudio(
      id: map['id'] as String,
      actividadId: map['actividad_id'] as String,
      planId: map['plan_id'] as String?,
      inicio: fecha(map['inicio']),
      fin: fecha(map['fin']),
      estado: EstadoBloque.fromDb(map['estado'] as String),
      avisoMin: map['aviso_min'] as int?,
      completadoEn: fechaONula(map['completado_en']),
      actividadTitulo: actividad?['titulo'] as String?,
      materiaNombre: materia?['nombre'] as String?,
      materiaColorHex: materia?['color'] as String?,
    );
  }

  final String id;
  final String actividadId;
  final String? planId;
  final DateTime inicio;
  final DateTime fin;
  final EstadoBloque estado;

  /// Minutos antes para avisar; nulo = sin aviso.
  final int? avisoMin;
  final DateTime? completadoEn;

  // Vienen solo si se pidió con [select].
  final String? actividadTitulo;
  final String? materiaNombre;
  final String? materiaColorHex;

  bool get esDelAsistente => planId != null;
  Duration get duracion => fin.difference(inicio);
  Color? get materiaColor => materiaColorHex == null ? null : colorDesdeHex(materiaColorHex!);

  /// ¿Se cruza con otro intervalo? (para no chocar con clases u otros bloques).
  bool seCruzaCon(DateTime otroInicio, DateTime otroFin) =>
      inicio.isBefore(otroFin) && otroInicio.isBefore(fin);

  Map<String, dynamic> toInsert() => {
        'actividad_id': actividadId,
        'plan_id': planId,
        'inicio': inicio.toUtc().toIso8601String(),
        'fin': fin.toUtc().toIso8601String(),
        'estado': estado.db,
        'aviso_min': avisoMin,
      };

  @override
  List<Object?> get props => [id, actividadId, planId, inicio, fin, estado, avisoMin, completadoEn];
}
