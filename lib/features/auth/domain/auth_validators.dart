/// Reglas de los formularios de acceso. Devuelven el mensaje de error, o
/// null si el valor está bien. Son Dart puro para poder probarlas solas.
abstract final class AuthValidators {
  static String? name(String value) =>
      value.trim().isEmpty ? 'Escribe tu nombre' : null;

  static String? email(String value) {
    final text = value.trim();
    if (text.isEmpty) return 'Escribe tu correo';
    final at = text.indexOf('@');
    final domain = at < 1 ? '' : text.substring(at + 1);
    if (at < 1 || !domain.contains('.') || domain.endsWith('.')) {
      return 'Revisa el correo, por ejemplo nombre@u.icesi.edu.co';
    }
    return null;
  }

  /// Contraseña nueva: mínimo 8 caracteres y al menos un número.
  static String? newPassword(String value) {
    if (value.isEmpty) return 'Escribe una contraseña';
    if (value.length < 8 || !value.contains(RegExp(r'[0-9]'))) {
      return 'Mínimo 8 caracteres, con al menos un número';
    }
    return null;
  }

  /// Contraseña al iniciar sesión: solo que no esté vacía.
  static String? password(String value) =>
      value.isEmpty ? 'Escribe tu contraseña' : null;
}
