import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';
import 'package:studyflow/features/tasks/domain/textos_actividad.dart';
import 'package:studyflow/features/tasks/domain/usecases/completar_actividad.dart';
import 'package:studyflow/features/tasks/domain/usecases/eliminar_actividad.dart';
import 'package:studyflow/features/tasks/domain/usecases/marcar_no_entregada.dart';
import 'package:studyflow/features/tasks/domain/usecases/marcar_presentado.dart';

/// Qué acabó de pasar en el detalle, para que la pantalla reaccione una vez
/// (abrir S1, cerrar al eliminar).
enum ResultadoDetalle { ninguno, completada, noEntregada, presentado, eliminada }

/// Lo que muestra S1 Tarea completada.
class ResumenCompletada extends Equatable {
  const ResumenCompletada({this.aTiempo, this.hechas, this.total, this.bloquesQuitados = const []});

  /// "2 días antes de la fecha límite." Nulo si se completó tarde.
  final String? aTiempo;

  /// Actividades cerradas de la materia y cuántas tiene. Nulos si no se pudo saber.
  final int? hechas;
  final int? total;

  /// Bloques pendientes que se cancelaron al completar.
  final List<BloqueEstudio> bloquesQuitados;

  @override
  List<Object?> get props => [aTiempo, hechas, total, bloquesQuitados];
}

class TaskDetailState extends Equatable {
  const TaskDetailState({
    required this.actividad,
    this.bloques = const [],
    this.cargandoBloques = true,
    this.ocupado = false,
    this.cambio = false,
    this.resultado = ResultadoDetalle.ninguno,
    this.resumen,
    this.aviso,
    this.avisoId = 0,
  });

  final Actividad actividad;

  /// Solo pendientes y hechos, ordenados por inicio.
  final List<BloqueEstudio> bloques;
  final bool cargandoBloques;

  /// Guardando una acción: los botones se desactivan.
  final bool ocupado;

  /// Algo se guardó: la lista de Tareas debe recargar al volver.
  final bool cambio;
  final ResultadoDetalle resultado;
  final ResumenCompletada? resumen;

  /// Error de una acción, para un SnackBar. [avisoId] cambia cada vez.
  final String? aviso;
  final int avisoId;

  TaskDetailState copyWith({
    Actividad? actividad,
    List<BloqueEstudio>? bloques,
    bool? cargandoBloques,
    bool? ocupado,
    bool? cambio,
    ResultadoDetalle? resultado,
    ResumenCompletada? resumen,
    String? aviso,
    int? avisoId,
  }) => TaskDetailState(
    actividad: actividad ?? this.actividad,
    bloques: bloques ?? this.bloques,
    cargandoBloques: cargandoBloques ?? this.cargandoBloques,
    ocupado: ocupado ?? this.ocupado,
    cambio: cambio ?? this.cambio,
    resultado: resultado ?? this.resultado,
    resumen: resumen ?? this.resumen,
    aviso: aviso ?? this.aviso,
    avisoId: avisoId ?? this.avisoId,
  );

  @override
  List<Object?> get props => [actividad, bloques, cargandoBloques, ocupado, cambio, resultado, resumen, aviso, avisoId];
}

/// Detalle de tarea (18) y de examen (29): carga los bloques y guarda las
/// acciones. Recibe la actividad que se tocó en la lista.
class TaskDetailCubit extends Cubit<TaskDetailState> {
  TaskDetailCubit(TasksRepository repositorio, Actividad actividad, {DateTime Function()? reloj})
    : _repositorio = repositorio,
      _completar = CompletarActividad(repositorio),
      _noEntregada = MarcarNoEntregada(repositorio),
      _presentar = MarcarPresentado(repositorio),
      _eliminar = EliminarActividad(repositorio),
      _reloj = reloj ?? DateTime.now,
      super(TaskDetailState(actividad: actividad));

  final TasksRepository _repositorio;
  final CompletarActividad _completar;
  final MarcarNoEntregada _noEntregada;
  final MarcarPresentado _presentar;
  final EliminarActividad _eliminar;
  final DateTime Function() _reloj;

  DateTime get ahora => _reloj();

  /// Bloques de la actividad. Si fallan, la tarjeta queda vacía y se avisa.
  Future<void> cargarBloques() async {
    try {
      final bloques = await _repositorio.bloquesDeActividad(state.actividad.id);
      emit(state.copyWith(bloques: bloquesVisibles(bloques), cargandoBloques: false));
    } catch (e) {
      emit(state.copyWith(cargandoBloques: false, aviso: mensajeDeError(e), avisoId: state.avisoId + 1));
    }
  }

  /// Al volver de Editar o de Nuevo bloque: trae la actividad y sus bloques de nuevo.
  Future<void> recargar() async {
    try {
      final actividad = await _repositorio.actividadPorId(state.actividad.id);
      if (actividad == null) {
        emit(state.copyWith(cambio: true, resultado: ResultadoDetalle.eliminada));
        return;
      }
      emit(state.copyWith(actividad: actividad, resultado: ResultadoDetalle.ninguno));
    } catch (e) {
      _avisar(e);
      return;
    }
    await cargarBloques();
  }

  Future<void> completar() => _guardar(() async {
    final pendientes = state.bloques.where((b) => b.estado == EstadoBloque.pendiente).toList();
    await _completar(state.actividad);
    final hechaEn = _reloj();
    final completada = state.actividad.copyWith(estado: EstadoActividad.completada, completadaEn: hechaEn);
    final (hechas, total) = await _progresoMateria(completada);
    emit(
      state.copyWith(
        actividad: completada,
        bloques: state.bloques.where((b) => b.estado != EstadoBloque.pendiente).toList(),
        resultado: ResultadoDetalle.completada,
        resumen: ResumenCompletada(
          aTiempo: mensajeATiempo(completada.fechaLimite, hechaEn),
          hechas: hechas,
          total: total,
          bloquesQuitados: pendientes,
        ),
      ),
    );
  });

  Future<void> marcarNoEntregada() => _guardar(() async {
    await _noEntregada(state.actividad, ahora: _reloj());
    emit(
      state.copyWith(
        actividad: state.actividad.copyWith(estado: EstadoActividad.noEntregada),
        resultado: ResultadoDetalle.noEntregada,
      ),
    );
  });

  Future<void> marcarPresentado() => _guardar(() async {
    await _presentar(state.actividad);
    emit(
      state.copyWith(
        actividad: state.actividad.copyWith(estado: EstadoActividad.presentado),
        resultado: ResultadoDetalle.presentado,
      ),
    );
  });

  Future<void> eliminar() => _guardar(() async {
    await _eliminar(state.actividad);
    emit(state.copyWith(resultado: ResultadoDetalle.eliminada));
  });

  /// Corre una acción: desactiva los botones mientras tanto y avisa si falla.
  Future<void> _guardar(Future<void> Function() accion) async {
    if (state.ocupado) return;
    emit(state.copyWith(ocupado: true, resultado: ResultadoDetalle.ninguno));
    try {
      await accion();
      emit(state.copyWith(ocupado: false, cambio: true));
    } catch (e) {
      emit(state.copyWith(ocupado: false));
      _avisar(e);
    }
  }

  void _avisar(Object e) => emit(state.copyWith(aviso: mensajeDeError(e), avisoId: state.avisoId + 1));

  /// "8 de 10 actividades" de la materia, contando la que se acaba de cerrar.
  /// Si no se puede saber, S1 no muestra la barra (no se inventa).
  Future<(int?, int?)> _progresoMateria(Actividad completada) async {
    final materiaId = completada.materiaId;
    if (materiaId == null) return (null, null);
    try {
      final todas = await _repositorio.actividadesDelPeriodo();
      final deLaMateria = [
        for (final a in todas)
          if (a.materiaId == materiaId) a.id == completada.id ? completada : a,
      ];
      final hechas = deLaMateria
          .where((a) => a.estado == EstadoActividad.completada || a.estado == EstadoActividad.presentado)
          .length;
      return (hechas, deLaMateria.length);
    } catch (_) {
      return (null, null);
    }
  }
}
