import 'dart:ui' show Color;

import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/models/hora.dart';
import 'package:studyflow/core/data/models/parse.dart';

/// Tabla `materias`.
class Materia extends Equatable {
  const Materia({
    required this.id,
    required this.periodoId,
    required this.nombre,
    required this.creditos,
    required this.colorHex,
    this.profesor,
    this.metaNota,
    this.horarios = const [],
    this.componentes = const [],
  });

  /// Select con sus horarios y componentes de nota.
  static const select = '*, horarios_clase(*), componentes_nota(*)';

  factory Materia.fromMap(Map<String, dynamic> map) => Materia(
        id: map['id'] as String,
        periodoId: map['periodo_id'] as String,
        nombre: map['nombre'] as String,
        profesor: map['profesor'] as String?,
        creditos: map['creditos'] as int,
        colorHex: map['color'] as String,
        metaNota: numeroONulo(map['meta_nota']),
        horarios: lista(map['horarios_clase']).map(HorarioClase.fromMap).toList(),
        componentes: lista(map['componentes_nota']).map(ComponenteNota.fromMap).toList(),
      );

  final String id;
  final String periodoId;
  final String nombre;
  final String? profesor;
  final int creditos;

  /// '#A78BFA'
  final String colorHex;
  final double? metaNota;

  /// Solo vienen si se pidió con [select].
  final List<HorarioClase> horarios;
  final List<ComponenteNota> componentes;

  Color get color => colorDesdeHex(colorHex);

  Map<String, dynamic> toInsert() => {
        'periodo_id': periodoId,
        'nombre': nombre,
        'profesor': profesor,
        'creditos': creditos,
        'color': colorHex,
        'meta_nota': metaNota,
      };

  @override
  List<Object?> get props => [id, periodoId, nombre, profesor, creditos, colorHex, metaNota, horarios, componentes];
}

/// Tabla `horarios_clase`: un día de clase de una materia.
class HorarioClase extends Equatable {
  const HorarioClase({
    required this.id,
    required this.materiaId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    this.salon,
  });

  factory HorarioClase.fromMap(Map<String, dynamic> map) => HorarioClase(
        id: map['id'] as String,
        materiaId: map['materia_id'] as String,
        diaSemana: map['dia_semana'] as int,
        horaInicio: Hora.fromDb(map['hora_inicio'] as String),
        horaFin: Hora.fromDb(map['hora_fin'] as String),
        salon: map['salon'] as String?,
      );

  final String id;
  final String materiaId;

  /// 1 = lunes … 7 = domingo (igual que DateTime.weekday).
  final int diaSemana;
  final Hora horaInicio;
  final Hora horaFin;
  final String? salon;

  Map<String, dynamic> toInsert() => {
        'materia_id': materiaId,
        'dia_semana': diaSemana,
        'hora_inicio': horaInicio.toDb(),
        'hora_fin': horaFin.toDb(),
        'salon': salon,
      };

  @override
  List<Object?> get props => [id, materiaId, diaSemana, horaInicio, horaFin, salon];
}

/// Tabla `componentes_nota`: una parte de la nota (Proyecto 40 %).
class ComponenteNota extends Equatable {
  const ComponenteNota({
    required this.id,
    required this.materiaId,
    required this.nombre,
    required this.porcentaje,
  });

  factory ComponenteNota.fromMap(Map<String, dynamic> map) => ComponenteNota(
        id: map['id'] as String,
        materiaId: map['materia_id'] as String,
        nombre: map['nombre'] as String,
        porcentaje: numero(map['porcentaje']),
      );

  final String id;
  final String materiaId;
  final String nombre;

  /// 40.0 = 40 %
  final double porcentaje;

  Map<String, dynamic> toInsert() => {
        'materia_id': materiaId,
        'nombre': nombre,
        'porcentaje': porcentaje,
      };

  @override
  List<Object?> get props => [id, materiaId, nombre, porcentaje];
}

/// '#A78BFA' → Color(0xFFA78BFA).
Color colorDesdeHex(String hex) {
  final limpio = hex.replaceFirst('#', '');
  return Color(int.parse(limpio.length == 6 ? 'FF$limpio' : limpio, radix: 16));
}
