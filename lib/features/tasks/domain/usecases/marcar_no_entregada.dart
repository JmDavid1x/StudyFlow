import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/tasks/domain/filtros_tareas.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';

/// Cierra una tarea o proyecto vencido que ya no se va a entregar.
class MarcarNoEntregada {
  const MarcarNoEntregada(this._repositorio);

  final TasksRepository _repositorio;

  /// Solo tareas o proyectos vencidos (pasó la fecha y no están cerrados).
  static bool puede(Actividad actividad, DateTime ahora) => !actividad.esExamen && esVencida(actividad, ahora);

  Future<void> call(Actividad actividad, {DateTime? ahora}) {
    if (!puede(actividad, ahora ?? DateTime.now())) {
      throw const AppException('Solo puedes marcar como no entregada una tarea vencida.');
    }
    return _repositorio.marcarNoEntregada(actividad.id);
  }
}
