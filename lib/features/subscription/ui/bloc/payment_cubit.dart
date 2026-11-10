import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';
import 'package:studyflow/features/subscription/domain/usecases/iniciar_prueba.dart';

/// En qué va el pago.
enum EtapaPago { eligiendo, enviando, activada }

class PaymentState extends Equatable {
  const PaymentState({
    required this.periodicidad,
    this.metodo = MetodoPago.tarjeta,
    this.estado = EtapaPago.eligiendo,
    this.suscripcion,
    this.error,
    this.errorId = 0,
  });

  /// El plan que llegó de StudyFlow Plus.
  final Periodicidad periodicidad;
  final MetodoPago metodo;
  final EtapaPago estado;

  /// La suscripción en prueba ya creada (estado activada), para la hoja S11.
  final Suscripcion? suscripcion;

  /// "Ya usaste tu prueba gratis." u otro error. [errorId] cambia cada vez.
  final String? error;
  final int errorId;

  PaymentState copyWith({
    MetodoPago? metodo,
    EtapaPago? estado,
    Suscripcion? suscripcion,
    String? error,
    int? errorId,
  }) => PaymentState(
    periodicidad: periodicidad,
    metodo: metodo ?? this.metodo,
    estado: estado ?? this.estado,
    suscripcion: suscripcion ?? this.suscripcion,
    error: error ?? this.error,
    errorId: errorId ?? this.errorId,
  );

  @override
  List<Object?> get props => [
    periodicidad,
    metodo,
    estado,
    suscripcion,
    error,
    errorId,
  ];
}

/// Pago (Figma 32 y S11): elige el método e inicia la prueba gratis. No hay
/// cobro hoy: la base deja un pago pendiente para cuando termine la prueba.
class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(
    SubscriptionRepository repositorio, {
    required Periodicidad periodicidad,
  }) : _iniciar = IniciarPrueba(repositorio),
       super(PaymentState(periodicidad: periodicidad));

  final IniciarPrueba _iniciar;

  void elegirMetodo(MetodoPago metodo) {
    emit(state.copyWith(metodo: metodo));
  }

  Future<void> iniciarPrueba() async {
    if (state.estado != EtapaPago.eligiendo) return;
    emit(state.copyWith(estado: EtapaPago.enviando));
    try {
      final suscripcion = await _iniciar(state.periodicidad, state.metodo);
      emit(
        state.copyWith(estado: EtapaPago.activada, suscripcion: suscripcion),
      );
    } catch (e) {
      emit(
        state.copyWith(
          estado: EtapaPago.eligiendo,
          error: mensajeDeError(e),
          errorId: state.errorId + 1,
        ),
      );
    }
  }
}
