import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';

/// Marca una tarea o proyecto como completado (también si ya venció).
/// El repositorio guarda completada_en y cancela sus bloques pendientes.
class CompletarActividad {
  const CompletarActividad(this._repositorio);

  final TasksRepository _repositorio;

  /// Tarea o proyecto que no esté cerrado: por hacer, en progreso o vencida.
  static bool puede(Actividad actividad) => !actividad.esExamen && !actividad.estado.estaCerrada;

  Future<void> call(Actividad actividad) {
    if (actividad.esExamen) {
      throw const AppException('Un examen se marca como presentado, no como completado.');
    }
    if (actividad.estado.estaCerrada) {
      throw const AppException('Esta actividad ya está cerrada.');
    }
    return _repositorio.completar(actividad.id);
  }
}
