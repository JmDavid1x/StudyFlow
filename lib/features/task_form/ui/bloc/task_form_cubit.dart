import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';
import 'package:studyflow/features/task_form/domain/usecases/guardar_actividad.dart';
import 'package:studyflow/features/task_form/ui/bloc/task_form_state.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form_data.dart';

/// Maneja Nueva tarea (14) y Editar tarea (19): carga las materias reales
/// para los selectores y guarda la actividad en Supabase.
class TaskFormCubit extends Cubit<TaskFormState> {
  /// GetIt le entrega el repositorio y el caso de uso (task_form_di.dart).
  /// Si no llega [guardar], se arma con el mismo repositorio.
  TaskFormCubit(TaskFormRepository repositorio, {GuardarActividad? guardar})
    : _repositorio = repositorio,
      _guardar = guardar ?? GuardarActividad(repositorio),
      super(const TaskFormState());

  final TaskFormRepository _repositorio;
  final GuardarActividad _guardar;

  /// Trae las materias con sus partes de la nota y lo que ya está asignado.
  Future<void> cargar() async {
    emit(const TaskFormState());
    try {
      final materias = await _repositorio.materiasConComponentes();
      final asignados = await _repositorio.porcentajesAsignados();
      emit(
        TaskFormState(
          status: TaskFormStatus.listo,
          materias: materias,
          asignados: asignados,
        ),
      );
    } on AppException catch (e) {
      emit(TaskFormState(status: TaskFormStatus.error, errorCarga: e.mensaje));
    }
  }

  /// Guarda lo del formulario. Sin [original] crea una actividad nueva; con
  /// [original] (Editar tarea) guarda los cambios sobre esa actividad.
  Future<void> guardar(TaskFormData datos, {Actividad? original}) async {
    if (state.guardando) return;
    emit(state.copyWith(guardando: true));
    try {
      final actividad = datos.toActividad(original: original);
      final guardada = original == null
          ? await _guardar.crear(actividad)
          : await _guardar.editar(actividad);
      emit(state.copyWith(guardando: false, guardada: guardada));
    } on AppException catch (e) {
      emit(state.copyWith(guardando: false, errorGuardar: e.mensaje));
    }
  }
}
