import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/models/enums.dart';
import 'package:studyflow/core/data/models/parse.dart';

/// Tabla `mensajes_asistente`: la conversación con el asistente.
class MensajeAsistente extends Equatable {
  const MensajeAsistente({
    required this.id,
    required this.perfilId,
    required this.rol,
    required this.contenido,
    required this.usadoRespaldo,
    required this.creadoEn,
  });

  factory MensajeAsistente.fromMap(Map<String, dynamic> map) => MensajeAsistente(
        id: map['id'] as String,
        perfilId: map['perfil_id'] as String,
        rol: RolMensaje.fromDb(map['rol'] as String),
        contenido: map['contenido'] as String,
        usadoRespaldo: map['usado_respaldo'] as bool,
        creadoEn: fecha(map['creado_en']),
      );

  final String id;
  final String perfilId;
  final RolMensaje rol;
  final String contenido;

  /// true si la IA no respondió y se usó el orden de respaldo (no gasta consulta).
  final bool usadoRespaldo;
  final DateTime creadoEn;

  /// Cuenta como consulta del plan gratis: respuesta de la IA, no de respaldo.
  bool get cuentaComoConsulta => rol == RolMensaje.asistente && !usadoRespaldo;

  Map<String, dynamic> toInsert() => {
        'perfil_id': perfilId,
        'rol': rol.db,
        'contenido': contenido,
        'usado_respaldo': usadoRespaldo,
      };

  @override
  List<Object?> get props => [id, perfilId, rol, contenido, usadoRespaldo, creadoEn];
}

/// Tabla `planes_estudio`: un plan que propuso el asistente.
class PlanEstudio extends Equatable {
  const PlanEstudio({
    required this.id,
    required this.perfilId,
    required this.tipo,
    required this.resumen,
    required this.usadoRespaldo,
    required this.activo,
    required this.creadoEn,
    this.mensajeId,
    this.actividades = const [],
  });

  /// Select con sus actividades en orden.
  static const select = '*, plan_actividades(*)';

  factory PlanEstudio.fromMap(Map<String, dynamic> map) => PlanEstudio(
        id: map['id'] as String,
        perfilId: map['perfil_id'] as String,
        mensajeId: map['mensaje_id'] as String?,
        tipo: TipoPlan.fromDb(map['tipo'] as String),
        resumen: map['resumen'] as String,
        usadoRespaldo: map['usado_respaldo'] as bool,
        activo: map['activo'] as bool,
        creadoEn: fecha(map['creado_en']),
        actividades: lista(map['plan_actividades']).map(PlanActividad.fromMap).toList()
          ..sort((a, b) => a.orden.compareTo(b.orden)),
      );

  final String id;
  final String perfilId;
  final String? mensajeId;
  final TipoPlan tipo;

  /// Texto de "Tu plan de hoy".
  final String resumen;
  final bool usadoRespaldo;
  final bool activo;
  final DateTime creadoEn;
  final List<PlanActividad> actividades;

  /// Para crear el plan (sus actividades se insertan aparte con PlanActividad.toInsert).
  Map<String, dynamic> toInsert() => {
        'perfil_id': perfilId,
        'mensaje_id': mensajeId,
        'tipo': tipo.db,
        'resumen': resumen,
        'usado_respaldo': usadoRespaldo,
        'activo': activo,
      };

  @override
  List<Object?> get props => [id, perfilId, mensajeId, tipo, resumen, usadoRespaldo, activo, creadoEn, actividades];
}

/// Tabla `plan_actividades`: qué actividad entra al plan y en qué orden.
class PlanActividad extends Equatable {
  const PlanActividad({
    required this.planId,
    required this.actividadId,
    required this.orden,
    required this.motivo,
    this.horasSugeridas,
  });

  factory PlanActividad.fromMap(Map<String, dynamic> map) => PlanActividad(
        planId: map['plan_id'] as String,
        actividadId: map['actividad_id'] as String,
        orden: map['orden'] as int,
        motivo: map['motivo'] as String,
        horasSugeridas: numeroONulo(map['horas_sugeridas']),
      );

  final String planId;
  final String actividadId;

  /// 1 = hacer primero.
  final int orden;

  /// 'Vence hoy a las 6:00 p. m.'
  final String motivo;
  final double? horasSugeridas;

  Map<String, dynamic> toInsert() => {
        'plan_id': planId,
        'actividad_id': actividadId,
        'orden': orden,
        'motivo': motivo,
        'horas_sugeridas': horasSugeridas,
      };

  @override
  List<Object?> get props => [planId, actividadId, orden, motivo, horasSugeridas];
}
