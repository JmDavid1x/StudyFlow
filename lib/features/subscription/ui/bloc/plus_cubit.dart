import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/assistant/domain/limite_consultas.dart';
import 'package:studyflow/features/profile/domain/profile_repository.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';

/// En qué va la carga de StudyFlow Plus.
enum EstadoPlus { cargando, listo, error }

class PlusState extends Equatable {
  const PlusState({
    this.estado = EstadoPlus.cargando,
    this.periodicidad = Periodicidad.mensual,
    this.limite = const LimiteConsultas(usadas: 0, esPlus: false),
    this.suscripcion,
    this.mensaje,
  });

  final EstadoPlus estado;

  /// Mensual o Semestre (el selector de Figma 30).
  final Periodicidad periodicidad;

  /// Consultas gratis usadas esta semana.
  final LimiteConsultas limite;

  /// La suscripción vigente, si ya es Plus.
  final Suscripcion? suscripcion;
  final String? mensaje;

  bool get esPlus => suscripcion?.esVigente ?? false;

  PlusState copyWith({
    EstadoPlus? estado,
    Periodicidad? periodicidad,
    LimiteConsultas? limite,
    Suscripcion? suscripcion,
    String? mensaje,
  }) => PlusState(
    estado: estado ?? this.estado,
    periodicidad: periodicidad ?? this.periodicidad,
    limite: limite ?? this.limite,
    suscripcion: suscripcion ?? this.suscripcion,
    mensaje: mensaje ?? this.mensaje,
  );

  @override
  List<Object?> get props => [
    estado,
    periodicidad,
    limite,
    suscripcion,
    mensaje,
  ];
}

/// StudyFlow Plus (Figma 30): consultas de la semana, si ya es Plus y el
/// plan elegido. Se crea en subscription_routes.dart.
class PlusCubit extends Cubit<PlusState> {
  PlusCubit(this._perfiles, this._suscripciones, {DateTime Function()? reloj})
    : _reloj = reloj ?? DateTime.now,
      super(const PlusState());

  final ProfileRepository _perfiles;
  final SubscriptionRepository _suscripciones;
  final DateTime Function() _reloj;

  Future<void> cargar() async {
    emit(state.copyWith(estado: EstadoPlus.cargando));
    try {
      final usadas = _perfiles.consultasUsadasEstaSemana(_reloj());
      final vigente = _suscripciones.suscripcionVigente();
      await Future.wait<Object?>([usadas, vigente]);
      final suscripcion = await vigente;
      emit(
        PlusState(
          estado: EstadoPlus.listo,
          periodicidad: state.periodicidad,
          suscripcion: suscripcion,
          limite: LimiteConsultas(
            usadas: await usadas,
            esPlus: suscripcion?.esVigente ?? false,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(estado: EstadoPlus.error, mensaje: mensajeDeError(e)),
      );
    }
  }

  void elegir(Periodicidad periodicidad) {
    emit(state.copyWith(periodicidad: periodicidad));
  }
}
