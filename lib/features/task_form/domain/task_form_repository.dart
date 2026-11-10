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

  /// Guarda los cambios de una actividad que ya existe.
  Future<Actividad> editarActividad(Actividad actividad);
}
