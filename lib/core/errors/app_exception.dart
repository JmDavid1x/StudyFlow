/// Errores de StudyFlow en Dart puro (sin Flutter ni Supabase), para que la
/// capa domain los pueda usar sin depender de la base de datos.
library;

/// Error que la UI ya puede mostrar tal cual (viene en español).
class AppException implements Exception {
  const AppException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Convierte un error técnico en un mensaje en español, o devuelve null si no
/// lo reconoce. main.dart registra el de Supabase al arrancar
/// (inversión de dependencias: el core no conoce a Supabase).
typedef TraductorDeErrores = String? Function(Object error);

TraductorDeErrores? traductorDeErrores;

/// Mensaje para el usuario a partir de cualquier error.
/// Los repositorios hacen: `catch (e) { throw AppException(mensajeDeError(e)); }`
String mensajeDeError(Object error) {
  if (error is AppException) return error.mensaje;
  return traductorDeErrores?.call(error) ?? 'Algo salió mal. Intenta de nuevo.';
}
