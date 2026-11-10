import 'package:studyflow/core/data/data.dart';

/// Qué datos necesitan los bloques de estudio (Figma 27, 28, S5 y S10). La
/// implementación con Supabase está en data/study_blocks_repository_impl.dart.
abstract class StudyBlocksRepository {
  /// Guarda un bloque nuevo y lo devuelve con su id, actividad y materia.
  Future<BloqueEstudio> crearBloque(BloqueEstudio bloque);

  /// estado = completado y completado_en = ahora.
  Future<void> completarBloque(String id);

  /// Cambia la hora del bloque y lo deja pendiente otra vez.
  Future<void> reprogramarBloque(String id, DateTime inicio, DateTime fin);

  /// estado = descartado. La actividad no se toca.
  Future<void> descartarBloque(String id);

  /// Bloques de una actividad, ordenados por inicio.
  Future<List<BloqueEstudio>> bloquesDeLaActividad(String actividadId);

  /// Estado actual de una actividad (para la regla de en_progreso).
  Future<EstadoActividad> estadoDeActividad(String actividadId);

  /// Pasa la actividad de por_hacer a en_progreso.
  Future<void> marcarActividadEnProgreso(String actividadId);

  /// La actividad completa (con su materia), para "Tarea vinculada".
  Future<Actividad> actividad(String id);

  /// Actividades del periodo activo que aún no se cierran, para elegir qué
  /// preparar en un bloque nuevo. Ordenadas por fecha límite.
  Future<List<Actividad>> actividadesAbiertas();
}
