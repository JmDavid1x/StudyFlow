import 'package:studyflow/core/data/data.dart';

/// Qué datos necesita Tareas (lista y detalle). La implementación con
/// Supabase está en data/tasks_repository_impl.dart.
abstract class TasksRepository {
  /// Actividades de las materias del periodo activo, ordenadas por fecha límite.
  Future<List<Actividad>> actividadesDelPeriodo();

  /// Una actividad con su materia (para recargar el detalle). Nula si ya no existe.
  Future<Actividad?> actividadPorId(String id);

  /// estado = completada, completada_en = ahora y cancela sus bloques pendientes.
  Future<void> completar(String id);

  /// Tarea o proyecto vencido que ya no se entregó.
  Future<void> marcarNoEntregada(String id);

  /// Examen que ya se presentó.
  Future<void> marcarPresentado(String id);

  /// Borra la actividad (sus bloques y notificaciones se borran en cascada).
  Future<void> eliminar(String id);

  /// Bloques de estudio de una actividad, ordenados por inicio.
  Future<List<BloqueEstudio>> bloquesDeActividad(String id);
}
