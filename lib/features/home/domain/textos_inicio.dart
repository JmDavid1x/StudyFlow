/// Textos de Inicio y Notificaciones. Dart puro: `ahora` llega por parámetro
/// para probarlo con fechas fijas.
library;

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/tasks/domain/textos_actividad.dart';

const _diasLargos = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
const _diasCortos = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// "Lunes, 9 de noviembre" (arriba del saludo).
String fechaDeHoy(DateTime ahora) => '${_diasLargos[ahora.weekday - 1]}, ${ahora.day} de ${_meses[ahora.month - 1]}';

/// "6 h", "1,5 h", "45 min", "0 h".
String horasTexto(Duration duracion) {
  final minutos = duracion.inMinutes;
  if (minutos == 0) return '0 h';
  if (minutos < 60) return '$minutos min';
  final horas = minutos / 60;
  final texto = horas == horas.roundToDouble()
      ? horas.toStringAsFixed(0)
      : horas.toStringAsFixed(1).replaceAll('.', ',');
  return '$texto h';
}

/// Tarjeta del próximo examen: el día ("Hoy", "Mañana", "Jue" o "24/11") y
/// "examen de Cálculo". Sin examen: "–" y "sin parciales".
(String, String) tarjetaExamen(Actividad? examen, DateTime ahora) {
  if (examen == null) return ('–', 'sin parciales');
  final fecha = examen.fechaLimite;
  final dia = switch (diasEntre(ahora, fecha)) {
    0 => 'Hoy',
    1 => 'Mañana',
    > 1 && < 7 => _diasCortos[fecha.weekday - 1],
    _ => '${fecha.day}/${fecha.month}',
  };
  final materia = examen.materiaNombre;
  return (dia, materia == null ? examen.titulo : 'examen de $materia');
}

/// Grupo de un aviso: "Hoy", "Ayer" o "Mié 4/11".
String grupoDelDia(DateTime fecha, DateTime ahora) => switch (diasEntre(fecha, ahora)) {
  0 => 'Hoy',
  1 => 'Ayer',
  _ => '${_diasCortos[fecha.weekday - 1]} ${fecha.day}/${fecha.month}',
};
