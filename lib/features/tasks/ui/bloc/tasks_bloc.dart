import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/tasks/domain/filtros_tareas.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';
import 'package:studyflow/features/tasks/domain/usecases/completar_actividad.dart';
import 'package:studyflow/features/tasks/domain/usecases/marcar_presentado.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

/// Pestaña Tareas: carga las actividades del periodo, las reparte en
/// secciones y guarda el chip elegido. Se crea en TasksScreen.
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc(TasksRepository repositorio, {DateTime Function()? reloj})
    : _repositorio = repositorio,
      _completar = CompletarActividad(repositorio),
      _presentar = MarcarPresentado(repositorio),
      _reloj = reloj ?? DateTime.now,
      super(const TasksState()) {
    on<TareasPedidas>(_onPedidas);
    on<FiltroCambiado>(_onFiltro);
    on<CirculoTocado>(_onCirculo);
  }

  final TasksRepository _repositorio;
  final CompletarActividad _completar;
  final MarcarPresentado _presentar;
  final DateTime Function() _reloj;

  Future<void> _onPedidas(TareasPedidas event, Emitter<TasksState> emit) async {
    // Al recargar (volver de otra pantalla) la lista sigue visible.
    if (state.estado != EstadoTareas.listo) emit(state.copyWith(estado: EstadoTareas.cargando));
    await _cargar(emit);
  }

  void _onFiltro(FiltroCambiado event, Emitter<TasksState> emit) => emit(state.copyWith(filtro: event.filtro));

  /// El círculo de una fila: completa la tarea o marca el examen como presentado.
  Future<void> _onCirculo(CirculoTocado event, Emitter<TasksState> emit) async {
    final actividad = event.actividad;
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
    await _cargar(emit);
  }

  Future<void> _cargar(Emitter<TasksState> emit) async {
    try {
      final actividades = await _repositorio.actividadesDelPeriodo();
      final ahora = _reloj();
      emit(
        state.copyWith(
          estado: actividades.isEmpty ? EstadoTareas.vacio : EstadoTareas.listo,
          grupos: agruparTareas(actividades, ahora),
          ahora: ahora,
        ),
      );
    } catch (e) {
      // Si ya había lista, se queda y solo se avisa.
      if (state.estado == EstadoTareas.listo) {
        emit(state.copyWith(aviso: mensajeDeError(e), avisoId: state.avisoId + 1));
      } else {
        emit(state.copyWith(estado: EstadoTareas.error, mensaje: mensajeDeError(e)));
      }
    }
  }
}
