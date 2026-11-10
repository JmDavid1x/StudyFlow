import 'package:studyflow/core/data/data.dart';

/// Qué datos necesitan StudyFlow Plus (Figma 30) y Pago (32 y S11). La
/// implementación con Supabase está en data/subscription_repository_impl.dart.
abstract class SubscriptionRepository {
  /// La suscripción en prueba o activa, o null si el usuario está en el plan gratis.
  Future<Suscripcion?> suscripcionVigente();

  /// Empieza la prueba gratis de 7 días y deja un pago simulado pendiente
  /// (se cobraría al terminar la prueba). Si ya usó su prueba, lanza
  /// "Ya usaste tu prueba gratis.".
  Future<Suscripcion> iniciarPrueba(
    Periodicidad periodicidad,
    MetodoPago metodo,
  );
}
