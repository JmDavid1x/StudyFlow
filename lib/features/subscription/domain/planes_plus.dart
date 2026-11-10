/// Reglas de StudyFlow Plus en Dart puro.
library;

import 'package:studyflow/core/data/data.dart';

/// Días de la prueba gratis (una sola vez por perfil).
const diasDePrueba = 7;

/// Lo que muestra la app cuando la base rechaza una segunda prueba (23505).
const mensajePruebaUsada = 'Ya usaste tu prueba gratis.';

/// Precio en pesos: mensual 9.900, semestral 39.900 (igual que el RPC iniciar_prueba).
int precioPlus(Periodicidad periodicidad) => switch (periodicidad) {
  Periodicidad.mensual => 9900,
  Periodicidad.semestral => 39900,
};

/// "Mensual" o "Semestre" (los textos del selector de Figma 30).
String nombrePlan(Periodicidad periodicidad) => switch (periodicidad) {
  Periodicidad.mensual => 'Mensual',
  Periodicidad.semestral => 'Semestre',
};

/// "al mes" o "por semestre".
String periodoDelCobro(Periodicidad periodicidad) => switch (periodicidad) {
  Periodicidad.mensual => 'al mes',
  Periodicidad.semestral => 'por semestre',
};

/// 9900 → "COP 9.900".
String formatoCop(int pesos) {
  final digitos = pesos.toString();
  final grupos = <String>[];
  for (var fin = digitos.length; fin > 0; fin -= 3) {
    grupos.insert(0, digitos.substring(fin - 3 < 0 ? 0 : fin - 3, fin));
  }
  return 'COP ${grupos.join('.')}';
}

/// Último día de la prueba y día del primer cobro: hoy + 7.
DateTime finDePrueba(DateTime hoy) =>
    DateTime(hoy.year, hoy.month, hoy.day + diasDePrueba);
