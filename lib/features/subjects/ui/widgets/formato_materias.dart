import 'package:studyflow/core/data/data.dart';

const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

/// "7:00 a. m.", "6:00 p. m."
String horaTexto(Hora hora) {
  final h12 = hora.hora % 12 == 0 ? 12 : hora.hora % 12;
  final sufijo = hora.hora < 12 ? 'a. m.' : 'p. m.';
  return '$h12:${hora.minuto.toString().padLeft(2, '0')} $sufijo';
}

/// "Mar y jue, 7:00 a. m." con los días que empiezan a la misma hora que el
/// primer horario. Nulo si la materia no tiene horarios.
String? horarioTexto(List<HorarioClase> horarios) {
  if (horarios.isEmpty) return null;
  final ordenados = [...horarios]
    ..sort((a, b) => a.diaSemana.compareTo(b.diaSemana));
  final inicio = ordenados.first.horaInicio;
  final dias = ordenados
      .where((h) => h.horaInicio == inicio)
      .map((h) => _dias[(h.diaSemana - 1) % 7])
      .toList();
  final lista = dias.length == 1
      ? dias.first
      : '${dias.sublist(0, dias.length - 1).join(', ')} y ${dias.last}';
  return '${lista[0].toUpperCase()}${lista.substring(1)}, ${horaTexto(inicio)}';
}

/// "lun 21/09"
String fechaCorta(DateTime fecha) {
  final dd = fecha.day.toString().padLeft(2, '0');
  final mm = fecha.month.toString().padLeft(2, '0');
  return '${_dias[fecha.weekday - 1]} $dd/$mm';
}

/// 4.0 → "4.0"; nulo → "–".
String notaTexto(double? nota) => nota == null ? '–' : nota.toStringAsFixed(1);
