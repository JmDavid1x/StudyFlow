import 'package:studyflow/core/data/data.dart';

/// Qué datos necesitan Perfil (Figma 25) y Ajustes de notificaciones (26).
/// La implementación con Supabase está en data/profile_repository_impl.dart.
abstract class ProfileRepository {
  /// Perfil de quien tiene la sesión, con su universidad.
  Future<Perfil> perfil();

  /// Cambia lo único editable del perfil y lo devuelve actualizado.
  Future<Perfil> actualizarPerfil({
    required String nombre,
    String? programa,
    int? semestre,
  });

  /// La fila de ajustes ya existe (la crea la base al registrarse).
  Future<AjustesNotificacion> ajustes();

  Future<void> guardarAjustes(AjustesNotificacion ajustes);

  /// El semestre activo (para mostrar su meta), o null si aún no lo crea.
  Future<Periodo?> periodoActivo();

  /// Consultas a la IA gastadas desde el lunes de la semana de [ahora].
  Future<int> consultasUsadasEstaSemana(DateTime ahora);
}
