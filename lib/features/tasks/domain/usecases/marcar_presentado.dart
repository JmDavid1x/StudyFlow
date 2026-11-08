import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';

/// Examen: pendiente → presentado.
class MarcarPresentado {
  const MarcarPresentado(this._repositorio);

  final TasksRepository _repositorio;

  static bool puede(Actividad actividad) => actividad.esExamen && actividad.estado == EstadoActividad.pendiente;

  Future<void> call(Actividad actividad) {
    if (!puede(actividad)) {
      throw const AppException('Solo un examen pendiente se puede marcar como presentado.');
    }
    return _repositorio.marcarPresentado(actividad.id);
  }
}
