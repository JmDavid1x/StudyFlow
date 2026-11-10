import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/assistant/domain/assistant_repository.dart';
import 'package:studyflow/features/assistant/domain/limite_consultas.dart';
import 'package:studyflow/features/assistant/domain/orden_respaldo.dart';
import 'package:studyflow/features/assistant/domain/usecases/agregar_al_plan.dart';
import 'package:studyflow/features/assistant/domain/usecases/enviar_pregunta.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';

part 'assistant_event.dart';
part 'assistant_state.dart';

/// Asistente (Figma 24, 31 y S4): la conversación guardada, el contador de
/// consultas, el orden sugerido y "Agregar al plan". Se crea en
/// assistant_routes.dart.
class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  AssistantBloc(
    this._repositorio,
    this._suscripciones, {
    DateTime Function()? reloj,
  }) : _reloj = reloj ?? DateTime.now,
       _enviar = EnviarPregunta(_repositorio, reloj: reloj),
       _agregar = AgregarAlPlan(_repositorio, reloj: reloj),
       super(const AssistantState()) {
    on<AsistenteIniciado>(_onIniciado);
    on<PreguntaEnviada>(_onPregunta);
    on<ReintentoPedido>(_onReintento);
    on<PlanPedido>(_onPlan);
  }

  final AssistantRepository _repositorio;
  final SubscriptionRepository _suscripciones;
  final DateTime Function() _reloj;
  final EnviarPregunta _enviar;
  final AgregarAlPlan _agregar;

  LimiteConsultas _limite(List<MensajeAsistente> mensajes, bool esPlus) =>
      LimiteConsultas(
        usadas: consultasUsadas(mensajes, _reloj()),
        esPlus: esPlus,
      );

  AssistantState _conAviso(Object error) => state.copyWith(
    enviando: false,
    agregando: false,
    aviso: mensajeDeError(error),
    avisoId: state.avisoId + 1,
  );

  Future<void> _onIniciado(
    AsistenteIniciado event,
    Emitter<AssistantState> emit,
  ) async {
    if (state.estado != EstadoAsistente.listo) {
      emit(state.copyWith(estado: EstadoAsistente.cargando));
    }
    try {
      final mensajes = _repositorio.historial();
      final suscripcion = _suscripciones.suscripcionVigente();
      await Future.wait<Object?>([mensajes, suscripcion]);
      final lista = await mensajes;
      emit(
        state.copyWith(
          estado: EstadoAsistente.listo,
          mensajes: lista,
          limite: _limite(lista, (await suscripcion)?.esVigente ?? false),
        ),
      );
    } catch (e) {
      if (state.estado == EstadoAsistente.listo) {
        emit(_conAviso(e));
      } else {
        emit(
          state.copyWith(
            estado: EstadoAsistente.error,
            mensaje: mensajeDeError(e),
          ),
        );
      }
    }
  }

  Future<void> _onPregunta(
    PreguntaEnviada event,
    Emitter<AssistantState> emit,
  ) async {
    if (event.texto.trim().isEmpty || state.enviando) return;
    emit(state.copyWith(enviando: true));
    try {
      final respuesta = await _enviar(event.texto, state.limite);
      final mensajes = [
        ...state.mensajes,
        respuesta.pregunta,
        respuesta.respuesta,
      ];
      emit(
        state.copyWith(
          enviando: false,
          mensajes: mensajes,
          limite: _limite(mensajes, state.limite.esPlus),
          orden: respuesta.orden,
          respuestaId: respuesta.respuesta.id,
        ),
      );
    } catch (e) {
      emit(_conAviso(e));
    }
  }

  Future<void> _onReintento(
    ReintentoPedido event,
    Emitter<AssistantState> emit,
  ) async {
    final pregunta = state.ultimaPregunta;
    if (pregunta == null || state.enviando) return;
    emit(state.copyWith(enviando: true));
    try {
      final respuesta = await _enviar.reintentar(pregunta);
      final mensajes = [...state.mensajes, respuesta];
      emit(
        state.copyWith(
          enviando: false,
          mensajes: mensajes,
          limite: _limite(mensajes, state.limite.esPlus),
          respuestaId: respuesta.id,
        ),
      );
    } on IaNoDisponible {
      emit(
        _conAviso(
          const AppException(
            'El asistente sigue sin responder. Puedes usar el orden de respaldo.',
          ),
        ),
      );
    } catch (e) {
      emit(_conAviso(e));
    }
  }

  Future<void> _onPlan(PlanPedido event, Emitter<AssistantState> emit) async {
    final orden = state.orden;
    if (orden == null || state.agregando) return;
    emit(state.copyWith(agregando: true));
    try {
      final respuesta = state.respuestaConOrden;
      final plan = await _agregar(
        orden,
        usadoRespaldo: respuesta?.usadoRespaldo ?? true,
        mensajeId: respuesta?.id,
      );
      emit(
        state.copyWith(
          agregando: false,
          planAgregado: plan,
          planId: state.planId + 1,
        ),
      );
    } catch (e) {
      emit(_conAviso(e));
    }
  }
}
