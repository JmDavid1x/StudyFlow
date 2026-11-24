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

/// Días que le quedan a la prueba gratis contando hoy (0 si ya terminó o
/// la suscripción no está en prueba).
int diasRestantesDePrueba(Suscripcion suscripcion, DateTime hoy) {
  final hasta = suscripcion.pruebaHasta;
  if (suscripcion.estado != EstadoSuscripcion.enPrueba || hasta == null) {
    return 0;
  }
  final dia = DateTime(hoy.year, hoy.month, hoy.day);
  final dias =
      (DateTime(hasta.year, hasta.month, hasta.day).difference(dia).inHours /
              24)
          .round();
  return dias < 0 ? 0 : dias;
}

/// "Te queda 1 día de prueba" o "Te quedan 5 días de prueba".
String textoDiasDePrueba(int dias) {
  if (dias <= 0) return 'Tu prueba gratis termina hoy';
  return dias == 1
      ? 'Te queda 1 día de prueba'
      : 'Te quedan $dias días de prueba';
}

/// Último día de la prueba y día del primer cobro: hoy + 7.
DateTime finDePrueba(DateTime hoy) =>
    DateTime(hoy.year, hoy.month, hoy.day + diasDePrueba);
