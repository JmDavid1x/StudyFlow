import 'package:studyflow/core/data/data.dart';

/// Lo que pasa con la sesión del usuario. Es del dominio: la UI no sabe nada
/// de Supabase, solo de estos eventos.
enum EventoSesion {
  /// Entró (login, registro con sesión o sesión guardada al abrir la app).
  inicio,

  /// Salió o la sesión venció.
  cierre,

  /// Abrió el enlace del correo de recuperación: debe crear una contraseña nueva.
  recuperacion,
}

/// Qué pasó al crear la cuenta.
enum ResultadoRegistro {
  /// La cuenta quedó lista y con sesión iniciada.
  conSesion,

  /// Supabase pide confirmar el correo antes de entrar.
  confirmarCorreo,
}

/// Acceso a la cuenta (Supabase Auth). La implementación está en data/.
abstract class AuthRepository {
  /// Avisa cada vez que cambia la sesión.
  Stream<EventoSesion> get eventos;

  /// Hay una sesión guardada en el celular.
  bool get haySesion;

  Future<List<Universidad>> universidades();

  /// Crea la cuenta. La base crea el perfil con [nombre] y [universidadId].
  Future<ResultadoRegistro> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
    required String universidadId,
  });

  Future<void> iniciarSesion({required String correo, required String contrasena});

  /// Manda el correo con el enlace para crear una contraseña nueva.
  Future<void> recuperarContrasena(String correo);

  /// Cambia la contraseña del usuario con sesión (después del enlace del correo).
  Future<void> cambiarContrasena(String nueva);

  Future<void> cerrarSesion();

  /// Perfil del usuario con sesión, o null si no hay sesión.
  Future<Perfil?> perfilActual();
}
