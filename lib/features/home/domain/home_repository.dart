import 'package:studyflow/core/data/data.dart';

/// Qué datos necesitan Inicio y Notificaciones. La implementación con
/// Supabase está en data/home_repository_impl.dart.
abstract class HomeRepository {
  /// Perfil de quien tiene la sesión (para el saludo).
  Future<Perfil> perfil();

  /// Actividades del periodo activo con fecha límite en [desde, hasta),
  /// ordenadas por fecha. El rango sale de [RangoInicio].
  Future<List<Actividad>> actividadesEntre(DateTime desde, DateTime hasta);

  /// El examen pendiente más cercano del periodo activo con fecha desde
  /// [desde], sin límite hacia adelante. Nulo si no hay.
  Future<Actividad?> proximoExamen(DateTime desde);

  /// Bloques de estudio que empiezan en [desde, hasta), ordenados por inicio.
  Future<List<BloqueEstudio>> bloquesEntre(DateTime desde, DateTime hasta);

  /// Bandeja de avisos, la más reciente primero.
  Future<List<Notificacion>> notificaciones();

  /// leida_en = ahora.
  Future<void> marcarLeida(String id);

  Future<void> borrarNotificacion(String id);
}
