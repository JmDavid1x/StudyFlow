import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/models/enums.dart';
import 'package:studyflow/core/data/models/hora.dart';
import 'package:studyflow/core/data/models/parse.dart';

/// Tabla `ajustes_notificacion`: una fila por perfil (la crea la base).
class AjustesNotificacion extends Equatable {
  const AjustesNotificacion({
    required this.perfilId,
    required this.pushActivas,
    required this.recordatorioEntregas,
    required this.diasAntes,
    required this.avisoMismoDia,
    required this.horasAntes,
    required this.avisoBloques,
    required this.minutosAntesBloque,
    required this.planDelDia,
    required this.horaPlan,
    required this.resumenSemanal,
    required this.diaResumen,
    required this.horaResumen,
  });

  factory AjustesNotificacion.fromMap(Map<String, dynamic> map) => AjustesNotificacion(
        perfilId: map['perfil_id'] as String,
        pushActivas: map['push_activas'] as bool,
        recordatorioEntregas: map['recordatorio_entregas'] as bool,
        diasAntes: map['dias_antes'] as int,
        avisoMismoDia: map['aviso_mismo_dia'] as bool,
        horasAntes: map['horas_antes'] as int,
        avisoBloques: map['aviso_bloques'] as bool,
        minutosAntesBloque: map['minutos_antes_bloque'] as int,
        planDelDia: map['plan_del_dia'] as bool,
        horaPlan: Hora.fromDb(map['hora_plan'] as String),
        resumenSemanal: map['resumen_semanal'] as bool,
        diaResumen: map['dia_resumen'] as int,
        horaResumen: Hora.fromDb(map['hora_resumen'] as String),
      );

  final String perfilId;
  final bool pushActivas;
  final bool recordatorioEntregas;
  final int diasAntes;
  final bool avisoMismoDia;
  final int horasAntes;
  final bool avisoBloques;
  final int minutosAntesBloque;
  final bool planDelDia;
  final Hora horaPlan;
  final bool resumenSemanal;

  /// 1 = lunes … 7 = domingo.
  final int diaResumen;
  final Hora horaResumen;

  /// Para `update` (sin perfil_id, que no cambia).
  Map<String, dynamic> toUpdate() => {
        'push_activas': pushActivas,
        'recordatorio_entregas': recordatorioEntregas,
        'dias_antes': diasAntes,
        'aviso_mismo_dia': avisoMismoDia,
        'horas_antes': horasAntes,
        'aviso_bloques': avisoBloques,
        'minutos_antes_bloque': minutosAntesBloque,
        'plan_del_dia': planDelDia,
        'hora_plan': horaPlan.toDb(),
        'resumen_semanal': resumenSemanal,
        'dia_resumen': diaResumen,
        'hora_resumen': horaResumen.toDb(),
      };

  AjustesNotificacion copyWith({
    bool? pushActivas,
    bool? recordatorioEntregas,
    int? diasAntes,
    bool? avisoMismoDia,
    int? horasAntes,
    bool? avisoBloques,
    int? minutosAntesBloque,
    bool? planDelDia,
    Hora? horaPlan,
    bool? resumenSemanal,
    int? diaResumen,
    Hora? horaResumen,
  }) =>
      AjustesNotificacion(
        perfilId: perfilId,
        pushActivas: pushActivas ?? this.pushActivas,
        recordatorioEntregas: recordatorioEntregas ?? this.recordatorioEntregas,
        diasAntes: diasAntes ?? this.diasAntes,
        avisoMismoDia: avisoMismoDia ?? this.avisoMismoDia,
        horasAntes: horasAntes ?? this.horasAntes,
        avisoBloques: avisoBloques ?? this.avisoBloques,
        minutosAntesBloque: minutosAntesBloque ?? this.minutosAntesBloque,
        planDelDia: planDelDia ?? this.planDelDia,
        horaPlan: horaPlan ?? this.horaPlan,
        resumenSemanal: resumenSemanal ?? this.resumenSemanal,
        diaResumen: diaResumen ?? this.diaResumen,
        horaResumen: horaResumen ?? this.horaResumen,
      );

  @override
  List<Object?> get props => [
        perfilId, pushActivas, recordatorioEntregas, diasAntes, avisoMismoDia, horasAntes,
        avisoBloques, minutosAntesBloque, planDelDia, horaPlan, resumenSemanal, diaResumen, horaResumen,
      ];
}

/// Tabla `notificaciones`: la bandeja de avisos.
class Notificacion extends Equatable {
  const Notificacion({
    required this.id,
    required this.perfilId,
    required this.tipo,
    required this.titulo,
    required this.cuerpo,
    required this.programadaPara,
    this.actividadId,
    this.bloqueId,
    this.enviadaEn,
    this.leidaEn,
  });

  factory Notificacion.fromMap(Map<String, dynamic> map) => Notificacion(
        id: map['id'] as String,
        perfilId: map['perfil_id'] as String,
        actividadId: map['actividad_id'] as String?,
        bloqueId: map['bloque_id'] as String?,
        tipo: TipoNotificacion.fromDb(map['tipo'] as String),
        titulo: map['titulo'] as String,
        cuerpo: map['cuerpo'] as String,
        programadaPara: fecha(map['programada_para']),
        enviadaEn: fechaONula(map['enviada_en']),
        leidaEn: fechaONula(map['leida_en']),
      );

  final String id;
  final String perfilId;

  /// Al tocarla abre esta actividad o este bloque.
  final String? actividadId;
  final String? bloqueId;
  final TipoNotificacion tipo;
  final String titulo;
  final String cuerpo;
  final DateTime programadaPara;
  final DateTime? enviadaEn;
  final DateTime? leidaEn;

  bool get leida => leidaEn != null;

  Map<String, dynamic> toInsert() => {
        'perfil_id': perfilId,
        'actividad_id': actividadId,
        'bloque_id': bloqueId,
        'tipo': tipo.db,
        'titulo': titulo,
        'cuerpo': cuerpo,
        'programada_para': programadaPara.toUtc().toIso8601String(),
      };

  @override
  List<Object?> get props => [id, perfilId, actividadId, bloqueId, tipo, titulo, cuerpo, programadaPara, enviadaEn, leidaEn];
}
