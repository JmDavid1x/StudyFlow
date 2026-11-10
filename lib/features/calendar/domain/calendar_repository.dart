import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/calendar/domain/horario_materia.dart';

/// Qué datos necesita el Calendario (Figma 20). La implementación con
/// Supabase está en data/calendar_repository_impl.dart.
abstract class CalendarRepository {
  /// Horarios de clase de las materias del periodo activo, con su materia.
  Future<List<HorarioMateria>> horarios();

  /// Entregas y exámenes del periodo activo con fecha límite en [desde, hasta).
  Future<List<Actividad>> actividadesEntre(DateTime desde, DateTime hasta);

  /// Bloques pendientes o completados que empiezan en [desde, hasta).
  Future<List<BloqueEstudio>> bloquesEntre(DateTime desde, DateTime hasta);
}
