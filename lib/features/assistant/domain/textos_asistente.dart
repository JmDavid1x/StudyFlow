/// Textos de fechas y horas para el asistente, en Dart puro (sin Flutter)
/// para que las reglas se puedan probar con tests.
library;

const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
const _meses = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// "6:00 p. m."
String textoHora(DateTime t) {
  final hora = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minuto = t.minute.toString().padLeft(2, '0');
  return '$hora:$minuto ${t.hour < 12 ? 'a. m.' : 'p. m.'}';
}

/// "jue 12 nov"
String textoDia(DateTime t) =>
    '${_dias[t.weekday - 1]} ${t.day} ${_meses[t.month - 1]}';

/// "30 %" o "12,5 %"
String textoPorcentaje(double valor) {
  final texto = valor == valor.roundToDouble()
      ? valor.toStringAsFixed(0)
      : valor.toStringAsFixed(1);
  return '${texto.replaceAll('.', ',')} %';
}

/// Medianoche del día de [t].
DateTime soloDia(DateTime t) => DateTime(t.year, t.month, t.day);

/// Días de calendario entre [desde] y [hasta] (0 = el mismo día).
int diasEntre(DateTime desde, DateTime hasta) =>
    (soloDia(hasta).difference(soloDia(desde)).inHours / 24).round();
