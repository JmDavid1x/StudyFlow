import 'package:studyflow/core/data/data.dart';

/// Si el correo es institucional, devuelve su universidad para preseleccionarla
/// en el registro (juan@u.icesi.edu.co → Universidad Icesi). Dart puro.
Universidad? universidadPorCorreo(String correo, List<Universidad> universidades) {
  for (final universidad in universidades) {
    if (correoEsDe(correo, universidad)) return universidad;
  }
  return null;
}

/// ¿El correo es de esa universidad? Acepta subdominios (profe@x.u.icesi.edu.co).
bool correoEsDe(String correo, Universidad universidad) {
  final arroba = correo.indexOf('@');
  if (arroba < 0) return false;
  final dominio = correo.substring(arroba + 1).trim().toLowerCase();
  return dominio == universidad.dominioCorreo || dominio.endsWith('.${universidad.dominioCorreo}');
}
