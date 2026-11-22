import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';

/// Marca una tarea o proyecto como completado (también si ya venció) y
/// cancela sus bloques pendientes.
///
/// Son dos cambios en la base. Para que no quede a medias (completada pero
/// con bloques pendientes), si falla el segundo se deshace el primero y se
/// lanza el error para que la pantalla lo muestre.
class CompletarActividad {
  const CompletarActividad(this._repositorio);

  final TasksRepository _repositorio;

  /// Mensaje si ni siquiera se pudo deshacer (la pantalla recarga para mostrar lo real).
  static const mensajeAMedias =
      'La tarea quedó completada, pero no pudimos quitar sus bloques de estudio. Revisa tu conexión y vuelve a abrirla.';

  /// Tarea o proyecto que no esté cerrado: por hacer, en progreso o vencida.
  static bool puede(Actividad actividad) => !actividad.esExamen && !actividad.estado.estaCerrada;

  Future<void> call(Actividad actividad) async {
    if (actividad.esExamen) {
      throw const AppException('Un examen se marca como presentado, no como completado.');
    }
    if (actividad.estado.estaCerrada) {
      throw const AppException('Esta actividad ya está cerrada.');
    }

    try {
      await _repositorio.marcarCompletada(actividad.id);
    } catch (e) {
      // No cambió nada: basta con avisar.
      throw AppException(mensajeDeError(e));
    }

    try {
      await _repositorio.cancelarBloquesPendientes(actividad.id);
    } catch (e) {
      try {
        await _repositorio.restaurarEstado(actividad.id, actividad.estado);
      } catch (_) {
        throw const AppException(mensajeAMedias);
      }
      // Quedó como estaba: se avisa el error original.
      throw AppException(mensajeDeError(e));
    }
  }
}
