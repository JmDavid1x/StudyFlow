import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';

/// Borra la actividad. La pantalla pide confirmación antes de llamarlo.
class EliminarActividad {
  const EliminarActividad(this._repositorio);

  final TasksRepository _repositorio;

  Future<void> call(Actividad actividad) => _repositorio.eliminar(actividad.id);
}
