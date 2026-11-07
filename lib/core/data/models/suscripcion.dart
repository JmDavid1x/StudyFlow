import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/models/enums.dart';
import 'package:studyflow/core/data/models/parse.dart';

/// Tabla `suscripciones`: StudyFlow Plus. El plan gratis no tiene fila.
class Suscripcion extends Equatable {
  const Suscripcion({
    required this.id,
    required this.perfilId,
    required this.periodicidad,
    required this.precioCop,
    required this.estado,
    required this.iniciaEn,
    required this.renovacionAutomatica,
    this.pruebaHasta,
    this.venceEn,
  });

  factory Suscripcion.fromMap(Map<String, dynamic> map) => Suscripcion(
        id: map['id'] as String,
        perfilId: map['perfil_id'] as String,
        periodicidad: Periodicidad.fromDb(map['periodicidad'] as String),
        precioCop: map['precio_cop'] as int,
        estado: EstadoSuscripcion.fromDb(map['estado'] as String),
        iniciaEn: dia(map['inicia_en']),
        pruebaHasta: diaONulo(map['prueba_hasta']),
        venceEn: diaONulo(map['vence_en']),
        renovacionAutomatica: map['renovacion_automatica'] as bool,
      );

  final String id;
  final String perfilId;
  final Periodicidad periodicidad;

  /// 9900 (mensual) · 39900 (semestral)
  final int precioCop;
  final EstadoSuscripcion estado;
  final DateTime iniciaEn;
  final DateTime? pruebaHasta;
  final DateTime? venceEn;
  final bool renovacionAutomatica;

  /// En prueba o activa = el usuario es Plus.
  bool get esVigente => estado == EstadoSuscripcion.enPrueba || estado == EstadoSuscripcion.activa;

  @override
  List<Object?> get props => [id, perfilId, periodicidad, precioCop, estado, iniciaEn, pruebaHasta, venceEn, renovacionAutomatica];
}

/// Tabla `pagos`: cada cobro. Nunca guarda datos de la tarjeta.
class Pago extends Equatable {
  const Pago({
    required this.id,
    required this.suscripcionId,
    required this.montoCop,
    required this.metodo,
    required this.estado,
    required this.referenciaPasarela,
    required this.creadoEn,
    this.pagadoEn,
  });

  factory Pago.fromMap(Map<String, dynamic> map) => Pago(
        id: map['id'] as String,
        suscripcionId: map['suscripcion_id'] as String,
        montoCop: map['monto_cop'] as int,
        metodo: MetodoPago.fromDb(map['metodo'] as String),
        estado: EstadoPago.fromDb(map['estado'] as String),
        referenciaPasarela: map['referencia_pasarela'] as String,
        creadoEn: fecha(map['creado_en']),
        pagadoEn: fechaONula(map['pagado_en']),
      );

  final String id;
  final String suscripcionId;
  final int montoCop;
  final MetodoPago metodo;
  final EstadoPago estado;
  final String referenciaPasarela;
  final DateTime creadoEn;
  final DateTime? pagadoEn;

  @override
  List<Object?> get props => [id, suscripcionId, montoCop, metodo, estado, referenciaPasarela, creadoEn, pagadoEn];
}
