import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';
import 'package:studyflow/features/auth/domain/usecases/cambiar_contrasena.dart';
import 'package:studyflow/features/auth/domain/usecases/cerrar_sesion.dart';
import 'package:studyflow/features/auth/domain/usecases/iniciar_sesion.dart';
import 'package:studyflow/features/auth/domain/usecases/obtener_universidades.dart';
import 'package:studyflow/features/auth/domain/usecases/recuperar_contrasena.dart';
import 'package:studyflow/features/auth/domain/usecases/registrar_usuario.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Estado de la cuenta para toda la app. Se crea una sola vez arriba de
/// MaterialApp (app.dart); cualquier pantalla lo lee con `context.read<AuthBloc>()`.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository)
      : _registrar = RegistrarUsuario(_repository),
        _iniciarSesion = IniciarSesion(_repository),
        _recuperar = RecuperarContrasena(_repository),
        _cambiarContrasena = CambiarContrasena(_repository),
        _cerrarSesion = CerrarSesion(_repository),
        _universidades = ObtenerUniversidades(_repository),
        super(const AuthState()) {
    on<AuthIniciado>(_onIniciado);
    on<_SesionCambio>(_onSesionCambio);
    on<UniversidadesPedidas>(_onUniversidades);
    on<RegistroPedido>(_onRegistro);
    on<InicioSesionPedido>(_onInicioSesion);
    on<RecuperacionPedida>(_onRecuperacion);
    on<CambioContrasenaPedido>(_onCambioContrasena);
    on<CerrarSesionPedido>(_onCerrarSesion);
  }

  final AuthRepository _repository;
  final RegistrarUsuario _registrar;
  final IniciarSesion _iniciarSesion;
  final RecuperarContrasena _recuperar;
  final CambiarContrasena _cambiarContrasena;
  final CerrarSesion _cerrarSesion;
  final ObtenerUniversidades _universidades;
  StreamSubscription<EventoSesion>? _suscripcion;

  Future<void> _onIniciado(AuthIniciado event, Emitter<AuthState> emit) async {
    emit(state.copyWith(sesion: _repository.haySesion ? Sesion.activa : Sesion.cerrada));
    await _suscripcion?.cancel();
    _suscripcion = _repository.eventos.listen((evento) => add(_SesionCambio(evento)));
  }

  void _onSesionCambio(_SesionCambio event, Emitter<AuthState> emit) {
    final sesion = switch (event.evento) {
      EventoSesion.inicio => Sesion.activa,
      EventoSesion.cierre => Sesion.cerrada,
      EventoSesion.recuperacion => Sesion.recuperacion,
    };
    emit(state.copyWith(sesion: sesion));
  }

  Future<void> _onUniversidades(UniversidadesPedidas event, Emitter<AuthState> emit) async {
    if (state.universidades.isNotEmpty) return;
    try {
      emit(state.copyWith(universidades: await _universidades()));
    } catch (e) {
      emit(state.copyWith(accion: AccionAuth.registro, estado: EstadoAccion.error, mensaje: mensajeDeError(e)));
    }
  }

  Future<void> _onRegistro(RegistroPedido event, Emitter<AuthState> emit) async {
    emit(state.copyWith(accion: AccionAuth.registro, estado: EstadoAccion.cargando));
    try {
      final resultado = await _registrar(
        nombre: event.nombre,
        correo: event.correo,
        contrasena: event.contrasena,
        universidadId: event.universidadId,
      );
      final perfil = resultado == ResultadoRegistro.conSesion ? await _repository.perfilActual() : null;
      emit(state.copyWith(
        accion: AccionAuth.registro,
        estado: EstadoAccion.exito,
        resultadoRegistro: resultado,
        perfil: perfil,
      ));
    } catch (e) {
      emit(state.copyWith(accion: AccionAuth.registro, estado: EstadoAccion.error, mensaje: mensajeDeError(e)));
    }
  }

  Future<void> _onInicioSesion(InicioSesionPedido event, Emitter<AuthState> emit) async {
    emit(state.copyWith(accion: AccionAuth.inicioSesion, estado: EstadoAccion.cargando));
    try {
      await _iniciarSesion(correo: event.correo, contrasena: event.contrasena);
      final perfil = await _repository.perfilActual();
      emit(state.copyWith(accion: AccionAuth.inicioSesion, estado: EstadoAccion.exito, perfil: perfil));
    } catch (e) {
      emit(state.copyWith(accion: AccionAuth.inicioSesion, estado: EstadoAccion.error, mensaje: mensajeDeError(e)));
    }
  }

  Future<void> _onRecuperacion(RecuperacionPedida event, Emitter<AuthState> emit) async {
    emit(state.copyWith(accion: AccionAuth.recuperacion, estado: EstadoAccion.cargando));
    try {
      final correo = await _recuperar(event.correo);
      emit(state.copyWith(accion: AccionAuth.recuperacion, estado: EstadoAccion.exito, correoEnviado: correo));
    } catch (e) {
      emit(state.copyWith(accion: AccionAuth.recuperacion, estado: EstadoAccion.error, mensaje: mensajeDeError(e)));
    }
  }

  Future<void> _onCambioContrasena(CambioContrasenaPedido event, Emitter<AuthState> emit) async {
    emit(state.copyWith(accion: AccionAuth.cambioContrasena, estado: EstadoAccion.cargando));
    try {
      await _cambiarContrasena(nueva: event.nueva, confirmacion: event.confirmacion);
      emit(state.copyWith(accion: AccionAuth.cambioContrasena, estado: EstadoAccion.exito, sesion: Sesion.activa));
    } catch (e) {
      emit(state.copyWith(
        accion: AccionAuth.cambioContrasena,
        estado: EstadoAccion.error,
        mensaje: mensajeDeError(e),
      ));
    }
  }

  Future<void> _onCerrarSesion(CerrarSesionPedido event, Emitter<AuthState> emit) async {
    emit(state.copyWith(accion: AccionAuth.cierreSesion, estado: EstadoAccion.cargando));
    try {
      await _cerrarSesion();
      // Se borra el perfil: el siguiente usuario empieza de cero.
      emit(AuthState(
        sesion: Sesion.cerrada,
        accion: AccionAuth.cierreSesion,
        estado: EstadoAccion.exito,
        universidades: state.universidades,
      ));
    } catch (e) {
      emit(state.copyWith(accion: AccionAuth.cierreSesion, estado: EstadoAccion.error, mensaje: mensajeDeError(e)));
    }
  }

  @override
  Future<void> close() async {
    await _suscripcion?.cancel();
    return super.close();
  }
}
