import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/tasks/domain/filtros_tareas.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';
import 'package:studyflow/features/tasks/domain/usecases/completar_actividad.dart';
import 'package:studyflow/features/tasks/domain/usecases/marcar_presentado.dart';
import 'package:studyflow/features/tasks/ui/bloc/agrupar_recargas.dart';

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
    // Una carga a la vez y en orden: una respuesta vieja no pisa a una nueva.
    on<TareasPedidas>(_onPedidas, transformer: (eventos, mapper) => eventos.asyncExpand(mapper));
    on<CambioEnVivo>((_, _) => _agrupar(() => add(const TareasPedidas())));
    on<FiltroCambiado>(_onFiltro);
    on<CirculoTocado>(_onCirculo);
  }

  final TasksRepository _repositorio;
  final CompletarActividad _completar;
  final MarcarPresentado _presentar;
  final DateTime Function() _reloj;
  final _agrupar = AgruparRecargas();

  @override
  Future<void> close() {
    _agrupar.cancelar();
    return super.close();
  }

  Future<void> _onPedidas(TareasPedidas event, Emitter<TasksState> emit) async {
    // Al recargar, lo que ya se ve (lista o estado vacío) se queda hasta que
    // llegue lo nuevo: así no parpadea el "Cargando…".
    final yaSeVe = state.estado == EstadoTareas.listo || state.estado == EstadoTareas.vacio;
    if (!yaSeVe) emit(state.copyWith(estado: EstadoTareas.cargando));
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
    }
    // También si falló: así la lista muestra lo que quedó guardado de verdad.
    await _cargar(emit);
  }

  Future<void> _cargar(Emitter<TasksState> emit) async {
    try {
      final actividades = await _repositorio.actividadesDelPeriodo();
      // Solo sin actividades importa saber si faltan las materias.
      final hayMaterias = actividades.isNotEmpty || await _repositorio.hayMaterias();
      final ahora = _reloj();
      emit(
        state.copyWith(
          estado: actividades.isEmpty ? EstadoTareas.vacio : EstadoTareas.listo,
          grupos: agruparTareas(actividades, ahora),
          vacio: () => vacioDeTareas(actividades: actividades, hayMaterias: hayMaterias),
          ahora: ahora,
        ),
      );
    } catch (e) {
      // Si ya se veía algo, se queda y solo se avisa.
      if (state.estado == EstadoTareas.listo || state.estado == EstadoTareas.vacio) {
        emit(state.copyWith(aviso: mensajeDeError(e), avisoId: state.avisoId + 1));
      } else {
        emit(state.copyWith(estado: EstadoTareas.error, mensaje: mensajeDeError(e)));
      }
    }
  }
}
