import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/home/domain/home_repository.dart';
import 'package:studyflow/features/home/domain/resumen_inicio.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';
import 'package:studyflow/features/tasks/domain/usecases/completar_actividad.dart';
import 'package:studyflow/features/tasks/domain/usecases/marcar_presentado.dart';

/// En qué va la carga de Inicio.
enum EstadoInicio { cargando, listo, error }

class HomeState extends Equatable {
  const HomeState({
    this.estado = EstadoInicio.cargando,
    this.nombre,
    this.resumen,
    this.ahora,
    this.mensaje,
    this.aviso,
    this.avisoId = 0,
  });

  final EstadoInicio estado;

  /// Primer nombre para "Hola, Santiago".
  final String? nombre;
  final ResumenInicio? resumen;

  /// Hora con la que se calculó (para que "hoy" y "mañana" coincidan).
  final DateTime? ahora;

  /// Error de la carga (estado error).
  final String? mensaje;

  /// Error de una acción, para un SnackBar. [avisoId] cambia cada vez.
  final String? aviso;
  final int avisoId;

  HomeState copyWith({
    EstadoInicio? estado,
    String? nombre,
    ResumenInicio? resumen,
    DateTime? ahora,
    String? mensaje,
    String? aviso,
    int? avisoId,
  }) => HomeState(
    estado: estado ?? this.estado,
    nombre: nombre ?? this.nombre,
    resumen: resumen ?? this.resumen,
    ahora: ahora ?? this.ahora,
    mensaje: mensaje ?? this.mensaje,
    aviso: aviso ?? this.aviso,
    avisoId: avisoId ?? this.avisoId,
  );

  // ResumenInicio no es Equatable: cada carga cuenta como estado nuevo.
  @override
  List<Object?> get props => [estado, nombre, resumen, ahora, mensaje, aviso, avisoId];
}

/// Pestaña Inicio: saludo, tarjetas, progreso semanal, prioridades de hoy,
/// próximas y el aviso del bloque de ayer. Se crea en HomeScreen.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._inicio, TasksRepository tareas, {DateTime Function()? reloj})
    : _completar = CompletarActividad(tareas),
      _presentar = MarcarPresentado(tareas),
      _reloj = reloj ?? DateTime.now,
      super(const HomeState());

  final HomeRepository _inicio;
  final CompletarActividad _completar;
  final MarcarPresentado _presentar;
  final DateTime Function() _reloj;

  /// Carga (o recarga al volver de otra pantalla). Al recargar, lo de antes
  /// sigue visible y solo se avisa si falla.
  Future<void> cargar() async {
    if (state.estado != EstadoInicio.listo) emit(state.copyWith(estado: EstadoInicio.cargando));
    final ahora = _reloj();
    final rango = RangoInicio(ahora);
    try {
      // Las cuatro consultas van a la vez; si una falla, llega su error.
      final perfil = _inicio.perfil();
      final actividades = _inicio.actividadesEntre(rango.desde, rango.hasta);
      final bloques = _inicio.bloquesEntre(rango.desde, rango.hasta);
      final notificaciones = _inicio.notificaciones();
      await Future.wait<Object>([perfil, actividades, bloques, notificaciones]);
      emit(
        state.copyWith(
          estado: EstadoInicio.listo,
          nombre: (await perfil).primerNombre,
          ahora: ahora,
          resumen: calcularResumenInicio(
            actividades: await actividades,
            bloques: await bloques,
            notificaciones: await notificaciones,
            ahora: ahora,
          ),
        ),
      );
    } catch (e) {
      final mensaje = mensajeDeError(e);
      if (state.estado == EstadoInicio.listo) {
        emit(state.copyWith(aviso: mensaje, avisoId: state.avisoId + 1));
      } else {
        emit(state.copyWith(estado: EstadoInicio.error, mensaje: mensaje));
      }
    }
  }

  /// El círculo de una fila: completa la tarea o marca el examen como presentado.
  Future<void> marcar(Actividad actividad) async {
    try {
      if (actividad.esExamen) {
        await _presentar(actividad);
      } else {
        await _completar(actividad);
      }
    } catch (e) {
      emit(state.copyWith(aviso: mensajeDeError(e), avisoId: state.avisoId + 1));
      return;
    }
    await cargar();
  }
}
