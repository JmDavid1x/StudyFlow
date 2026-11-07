import 'package:studyflow/core/data/data.dart';

/// Si el correo es institucional, devuelve su universidad para preseleccionarla
/// en el registro (juan@u.icesi.edu.co → Universidad Icesi). Dart puro.
Universidad? universidadPorCorreo(String correo, List<Universidad> universidades) {
  final arroba = correo.indexOf('@');
  if (arroba < 0) return null;
  final dominio = correo.substring(arroba + 1).trim().toLowerCase();
  for (final universidad in universidades) {
    if (universidad.dominioCorreo == dominio) return universidad;
  }
  return null;
}
