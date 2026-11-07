import 'dart:ui' show Color;

import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/models/enums.dart';
import 'package:studyflow/core/data/models/materia.dart';
import 'package:studyflow/core/data/models/parse.dart';

/// Tabla `actividades`: tareas, proyectos y exámenes. Es la tabla central.
///
/// La materia NO se guarda en la actividad: sale de su componente
/// (actividad → componente_nota → materia). Pidiendo [select] llegan
/// el componente y la materia anidados, y quedan en [materiaId],
/// [materiaNombre], [materiaColorHex] y [componenteNombre].
class Actividad extends Equatable {
  const Actividad({
    required this.id,
    required this.componenteId,
    required this.titulo,
    required this.tipo,
    required this.fechaLimite,
    required this.porcentaje,
    required this.prioridad,
    required this.estado,
    required this.recordatorio,
    required this.creadoEn,
    required this.actualizadoEn,
    this.canalEntrega,
    this.lugar,
    this.notas,
    this.completadaEn,
    this.componenteNombre,
    this.materiaId,
    this.materiaNombre,
    this.materiaColorHex,
  });

  /// Select con el componente y la materia (para mostrar "Bases de Datos" y su color).
  static const select = '*, componentes_nota(id, nombre, materia_id, materias(id, nombre, color))';

  /// Igual que [select], pero obliga a que la materia sea del periodo activo.
  /// Úsalo con `.eq('componentes_nota.materias.periodos.activo', true)`.
  static const selectPeriodoActivo =
      '*, componentes_nota!inner(id, nombre, materia_id, materias!inner(id, nombre, color, periodos!inner(activo)))';

  factory Actividad.fromMap(Map<String, dynamic> map) {
    final componente = anidado(map['componentes_nota']);
    final materia = anidado(componente?['materias']);
    return Actividad(
      id: map['id'] as String,
      componenteId: map['componente_id'] as String,
      titulo: map['titulo'] as String,
      tipo: TipoActividad.fromDb(map['tipo'] as String),
      fechaLimite: fecha(map['fecha_limite']),
      canalEntrega: map['canal_entrega'] == null ? null : CanalEntrega.fromDb(map['canal_entrega'] as String),
      lugar: map['lugar'] as String?,
      porcentaje: numero(map['porcentaje']),
      prioridad: Prioridad.fromDb(map['prioridad'] as String),
      estado: EstadoActividad.fromDb(map['estado'] as String),
      recordatorio: map['recordatorio'] as bool,
      notas: map['notas'] as String?,
      completadaEn: fechaONula(map['completada_en']),
      creadoEn: fecha(map['creado_en']),
      actualizadoEn: fecha(map['actualizado_en']),
      componenteNombre: componente?['nombre'] as String?,
      materiaId: materia?['id'] as String?,
      materiaNombre: materia?['nombre'] as String?,
      materiaColorHex: materia?['color'] as String?,
    );
  }

  final String id;
  final String componenteId;
  final String titulo;
  final TipoActividad tipo;
  final DateTime fechaLimite;

  /// Nulo en los exámenes.
  final CanalEntrega? canalEntrega;

  /// Solo exámenes: 'Salón 302'.
  final String? lugar;

  /// Valor en la nota final (15.0 = 15 %). 0 si no cuenta.
  final double porcentaje;
  final Prioridad prioridad;
  final EstadoActividad estado;
  final bool recordatorio;
  final String? notas;
  final DateTime? completadaEn;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  // Vienen solo si se pidió con [select] o [selectPeriodoActivo].
  final String? componenteNombre;
  final String? materiaId;
  final String? materiaNombre;
  final String? materiaColorHex;

  bool get esExamen => tipo == TipoActividad.examen;

  Color? get materiaColor => materiaColorHex == null ? null : colorDesdeHex(materiaColorHex!);

  /// Ya pasó la fecha y no está cerrada (completada, no entregada o presentado).
  bool estaVencida([DateTime? ahora]) =>
      !estado.estaCerrada && fechaLimite.isBefore(ahora ?? DateTime.now());

  /// Para insertar (id y fechas los pone la base).
  Map<String, dynamic> toInsert() => {
        'componente_id': componenteId,
        'titulo': titulo,
        'tipo': tipo.db,
        'fecha_limite': fechaLimite.toUtc().toIso8601String(),
        'canal_entrega': canalEntrega?.db,
        'lugar': lugar,
        'porcentaje': porcentaje,
        'prioridad': prioridad.db,
        'estado': estado.db,
        'recordatorio': recordatorio,
        'notas': notas,
      };

  Actividad copyWith({
    String? componenteId,
    String? titulo,
    TipoActividad? tipo,
    DateTime? fechaLimite,
    CanalEntrega? canalEntrega,
    String? lugar,
    double? porcentaje,
    Prioridad? prioridad,
    EstadoActividad? estado,
    bool? recordatorio,
    String? notas,
    DateTime? completadaEn,
  }) =>
      Actividad(
        id: id,
        componenteId: componenteId ?? this.componenteId,
        titulo: titulo ?? this.titulo,
        tipo: tipo ?? this.tipo,
        fechaLimite: fechaLimite ?? this.fechaLimite,
        canalEntrega: canalEntrega ?? this.canalEntrega,
        lugar: lugar ?? this.lugar,
        porcentaje: porcentaje ?? this.porcentaje,
        prioridad: prioridad ?? this.prioridad,
        estado: estado ?? this.estado,
        recordatorio: recordatorio ?? this.recordatorio,
        notas: notas ?? this.notas,
        completadaEn: completadaEn ?? this.completadaEn,
        creadoEn: creadoEn,
        actualizadoEn: actualizadoEn,
        componenteNombre: componenteNombre,
        materiaId: materiaId,
        materiaNombre: materiaNombre,
        materiaColorHex: materiaColorHex,
      );

  @override
  List<Object?> get props => [
        id, componenteId, titulo, tipo, fechaLimite, canalEntrega, lugar, porcentaje,
        prioridad, estado, recordatorio, notas, completadaEn, creadoEn, actualizadoEn,
      ];
}
