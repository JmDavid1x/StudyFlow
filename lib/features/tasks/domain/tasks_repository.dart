import 'package:studyflow/core/data/data.dart';

/// Qué datos necesita Tareas (lista y detalle). La implementación con
/// Supabase está en data/tasks_repository_impl.dart.
abstract class TasksRepository {
  /// Actividades de las materias del periodo activo, ordenadas por fecha límite.
  Future<List<Actividad>> actividadesDelPeriodo();

  /// Si el periodo activo tiene al menos una materia (para el estado vacío).
  Future<bool> hayMaterias();

  /// Una actividad con su materia (para recargar el detalle). Nula si ya no existe.
  Future<Actividad?> actividadPorId(String id);

  /// estado = completada y completada_en = ahora. Lo usa [CompletarActividad],
  /// que además cancela los bloques y revierte si algo falla.
  Future<void> marcarCompletada(String id);

  /// Pasa a cancelado los bloques pendientes de la actividad (un solo update).
  Future<void> cancelarBloquesPendientes(String actividadId);

  /// Devuelve la actividad al [estado] que tenía (la base borra completada_en
  /// sola si el estado ya no es completada). Sirve para deshacer un completar.
  Future<void> restaurarEstado(String id, EstadoActividad estado);

  /// Tarea o proyecto vencido que ya no se entregó.
  Future<void> marcarNoEntregada(String id);

  /// Examen que ya se presentó.
  Future<void> marcarPresentado(String id);

  /// Borra la actividad (sus bloques y notificaciones se borran en cascada).
  Future<void> eliminar(String id);

  /// Bloques de estudio de una actividad, ordenados por inicio.
  Future<List<BloqueEstudio>> bloquesDeActividad(String id);
}
