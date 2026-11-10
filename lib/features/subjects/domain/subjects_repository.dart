import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subjects/domain/actividad_con_nota.dart';

/// QUÉ datos necesita la feature Materias (el CÓMO está en data/).
/// Todos los métodos lanzan `AppException` con un mensaje listo para mostrar.
abstract class SubjectsRepository {
  /// El periodo (semestre) activo, o null si aún no hay.
  Future<Periodo?> periodoActivo();

  /// Crea el periodo activo del usuario con sesión.
  Future<Periodo> crearPeriodo({
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    double? metaPromedio,
  });

  /// Materias del periodo activo con sus horarios y componentes.
  Future<List<Materia>> materiasDelPeriodo();

  /// Guarda la materia con sus horarios y componentes. Los ids de [materia],
  /// [horarios] y [componentes] se ignoran (los pone la base). Devuelve la
  /// materia creada con todo su detalle.
  Future<Materia> crearMateria(
    Materia materia,
    List<HorarioClase> horarios,
    List<ComponenteNota> componentes,
  );

  /// Actividades de la materia, cada una con su calificación si ya la tiene.
  Future<List<ActividadConNota>> actividadesConNota(String materiaId);

  /// Guarda (o cambia) la nota de una actividad: hay una sola por actividad.
  Future<void> registrarNota(String actividadId, double nota);

  /// Marca la configuración inicial como completa y guarda si se activaron
  /// los recordatorios (push).
  Future<void> terminarConfiguracion({required bool pushActivas});
}
