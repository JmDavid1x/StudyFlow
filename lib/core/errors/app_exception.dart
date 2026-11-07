import 'package:supabase_flutter/supabase_flutter.dart';

/// Error que la UI ya puede mostrar tal cual (viene en español).
class AppException implements Exception {
  const AppException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Convierte cualquier error de Supabase o de red en un mensaje para el usuario.
/// Los repositorios hacen: `catch (e) { throw AppException(mensajeDeError(e)); }`
String mensajeDeError(Object error) {
  if (error is AppException) return error.mensaje;

  if (error is AuthException) {
    return switch (error.code) {
      'invalid_credentials' => 'Correo o contraseña incorrectos.',
      'email_not_confirmed' => 'Confirma tu correo antes de iniciar sesión.',
      'user_already_exists' || 'email_exists' => 'Ya existe una cuenta con ese correo.',
      'weak_password' => 'La contraseña es muy débil.',
      'over_email_send_rate_limit' || 'over_request_rate_limit' =>
        'Hiciste muchos intentos. Espera unos minutos y vuelve a intentar.',
      'same_password' => 'La nueva contraseña debe ser distinta a la anterior.',
      _ => 'No pudimos validar tu cuenta. Intenta de nuevo.',
    };
  }

  if (error is PostgrestException) {
    return switch (error.code) {
      '23505' => 'Eso ya existe.',
      '23514' || '22P02' => 'Algún dato no es válido.',
      '23503' => 'Falta un dato relacionado (por ejemplo, la materia).',
      '42501' => 'No tienes permiso para hacer esto.',
      _ => 'No pudimos guardar los cambios. Intenta de nuevo.',
    };
  }

  final texto = error.toString();
  if (texto.contains('SocketException') || texto.contains('ClientException') || texto.contains('Failed host lookup')) {
    return 'Sin conexión. Revisa tu internet e intenta de nuevo.';
  }
  return 'Algo salió mal. Intenta de nuevo.';
}
