import 'package:studyflow/core/data/data.dart';

/// Lo que ya está asignado de un componente: una actividad y cuánto vale.
typedef PorcentajeAsignado = ({
  String actividadId,
  String componenteId,
  double porcentaje,
});

/// Qué datos necesita el formulario de tarea (Figma 14 y 19). La
/// implementación con Supabase está en data/task_form_repository_impl.dart.
abstract class TaskFormRepository {
  /// Materias del periodo activo con sus componentes de nota, para los
  /// selectores de materia y "Parte de la nota".
  Future<List<Materia>> materiasConComponentes();

  /// Porcentaje que ya usa cada actividad del periodo activo, para mostrar
  /// "quedan X % sin asignar" en el componente elegido.
  Future<List<PorcentajeAsignado>> porcentajesAsignados();

  /// Guarda una actividad nueva y la devuelve con su id y su materia.
  Future<Actividad> crearActividad(Actividad actividad);

  /// Guarda los cambios de una actividad que ya existe. No reenvía el estado
  /// (lo maneja Inicio al marcarla) ni completada_en (lo pone la base), salvo
  /// [cambiarEstado]: cuando pasa de examen a tarea o al revés, el estado que
  /// tenía ya no vale para el nuevo tipo y hay que mandarlo.
  Future<Actividad> editarActividad(
    Actividad actividad, {
    required bool cambiarEstado,
  });
}
