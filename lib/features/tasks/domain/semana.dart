/// Ayudas de fechas en Dart puro. "La semana" va de lunes a domingo, igual
/// que el calendario. Se usan en Tareas y en Inicio.
library;

/// Medianoche del día de [fecha].
DateTime inicioDelDia(DateTime fecha) => DateTime(fecha.year, fecha.month, fecha.day);

/// Medianoche del día siguiente (límite exclusivo del día).
DateTime finDelDia(DateTime fecha) => DateTime(fecha.year, fecha.month, fecha.day + 1);

/// Lunes a las 00:00 de la semana de [fecha].
DateTime inicioDeSemana(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day - (fecha.weekday - DateTime.monday));

/// Lunes siguiente a las 00:00 (límite exclusivo de la semana).
DateTime finDeSemana(DateTime fecha) {
  final lunes = inicioDeSemana(fecha);
  return DateTime(lunes.year, lunes.month, lunes.day + 7);
}

/// ¿[fecha] cae en el intervalo [desde, hasta)?
bool estaEntre(DateTime fecha, DateTime desde, DateTime hasta) => !fecha.isBefore(desde) && fecha.isBefore(hasta);

bool esMismoDia(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
