import 'package:supabase_flutter/supabase_flutter.dart';

/// Traduce los errores de Supabase (Auth, base de datos y red) a mensajes en
/// español. Se registra en main.dart: `traductorDeErrores = traducirErrorDeSupabase;`
String? traducirErrorDeSupabase(Object error) {
  // Sin internet o servidor caído: Supabase Auth lanza esta excepción sin código.
  if (error is AuthRetryableFetchException) return _sinConexion;

  if (error is AuthException) {
    return switch (error.code) {
      'invalid_credentials' => 'Correo o contraseña incorrectos.',
      'email_not_confirmed' => 'Confirma tu correo antes de iniciar sesión.',
      'user_already_exists' || 'email_exists' => 'Ya existe una cuenta con ese correo.',
      'weak_password' => 'La contraseña es muy débil.',
      'over_email_send_rate_limit' || 'over_request_rate_limit' =>
        'Hiciste muchos intentos. Espera unos minutos y vuelve a intentar.',
      'same_password' => 'La nueva contraseña debe ser distinta a la anterior.',
      'session_not_found' || 'refresh_token_not_found' => 'Tu sesión venció. Inicia sesión de nuevo.',
      _ => 'No pudimos validar tu cuenta. Intenta de nuevo.',
    };
  }

  if (error is PostgrestException) {
    return switch (error.code) {
      '23505' => 'Eso ya existe.',
      '23514' || '22P02' => 'Algún dato no es válido.',
      '23503' => 'Falta un dato relacionado (por ejemplo, la materia).',
      '42501' => 'No tienes permiso para hacer esto.',
      'PGRST116' => 'No encontramos lo que buscabas.',
      _ => 'No pudimos completar la acción. Intenta de nuevo.',
    };
  }

  final texto = error.toString();
  if (texto.contains('SocketException') || texto.contains('ClientException') || texto.contains('Failed host lookup')) {
    return _sinConexion;
  }
  return null;
}

const _sinConexion = 'Sin conexión. Revisa tu internet e intenta de nuevo.';
