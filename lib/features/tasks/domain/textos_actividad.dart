/// Textos que se muestran de una actividad: fechas, tiempo que falta, canal y
/// parte de la nota. Dart puro: `ahora` llega por parámetro para probarlo.
library;

import 'package:studyflow/core/data/data.dart';

const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

String _dosDigitos(int n) => n.toString().padLeft(2, '0');

String _mayuscula(String texto) => texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

bool _esManana(DateTime hora) => hora.hour < 12;

/// Días de calendario de [desde] a [hasta] (no cuenta horas): ayer = -1.
int diasEntre(DateTime desde, DateTime hasta) => DateTime.utc(
  hasta.year,
  hasta.month,
  hasta.day,
).difference(DateTime.utc(desde.year, desde.month, desde.day)).inDays;

/// "11:59 p. m.", "7:00 a. m.". Sin el sufijo: "2:00".
String hora(DateTime fecha, {bool conSufijo = true}) {
  final h = fecha.hour % 12 == 0 ? 12 : fecha.hour % 12;
  final texto = '$h:${_dosDigitos(fecha.minute)}';
  if (!conSufijo) return texto;
  return '$texto ${_esManana(fecha) ? 'a. m.' : 'p. m.'}';
}

/// Para las listas: "hoy 11:59 p. m.", "mañana 2:00 p. m.", "ayer 6:00 p. m.",
/// "jue 2:00 p. m." (esta semana que viene) o "23/09 · 2:00 p. m.".
String fechaCorta(DateTime fecha, DateTime ahora) {
  final dias = diasEntre(ahora, fecha);
  final cuando = switch (dias) {
    0 => 'hoy',
    1 => 'mañana',
    -1 => 'ayer',
    > 1 && < 7 => _dias[fecha.weekday - 1],
    _ => '${_dosDigitos(fecha.day)}/${_dosDigitos(fecha.month)} ·',
  };
  return '$cuando ${hora(fecha)}';
}

/// Para el detalle: "Mié 23/09 · 11:59 p. m.", "Hoy · 11:59 p. m.".
String fechaLarga(DateTime fecha, DateTime ahora) {
  final cuando = switch (diasEntre(ahora, fecha)) {
    0 => 'Hoy',
    1 => 'Mañana',
    -1 => 'Ayer',
    _ => '${_mayuscula(_dias[fecha.weekday - 1])} ${_dosDigitos(fecha.day)}/${_dosDigitos(fecha.month)}',
  };
  return '$cuando · ${hora(fecha)}';
}

/// "mar 22" (día de la semana y número).
String diaCorto(DateTime fecha) => '${_dias[fecha.weekday - 1]} ${fecha.day}';

/// "Dom 20 · 2:00 – 4:00 p. m." o "Mar 22 · 10:00 a. m. – 12:00 p. m.".
String rangoBloque(DateTime inicio, DateTime fin) {
  final dia = _mayuscula(diaCorto(inicio));
  final mismoSufijo = _esManana(inicio) == _esManana(fin);
  return '$dia · ${hora(inicio, conSufijo: !mismoSufijo)} – ${hora(fin)}';
}

/// "Faltan 2 días", "Vence mañana", "Vence hoy", "Vencida". Nulo si ya se cerró.
String? tiempoRestante(Actividad actividad, DateTime ahora) {
  if (actividad.estado.estaCerrada) return null;
  if (actividad.estaVencida(ahora)) return 'Vencida';
  return switch (diasEntre(ahora, actividad.fechaLimite)) {
    0 => 'Vence hoy',
    1 => 'Vence mañana',
    final dias => 'Faltan $dias días',
  };
}

/// Para la fila de una vencida: "venció hoy", "venció ayer", "venció hace 3 días".
String vencio(DateTime fecha, DateTime ahora) => switch (diasEntre(fecha, ahora)) {
  <= 0 => 'venció hoy',
  1 => 'venció ayer',
  final dias => 'venció hace $dias días',
};

/// Subtítulo de una fila de las listas: "Bases de Datos · hoy 11:59 p. m.".
String subtituloActividad(Actividad actividad, DateTime ahora) {
  final materia = actividad.materiaNombre ?? 'Sin materia';
  if (actividad.estado.estaCerrada) {
    final texto = switch (actividad.estado) {
      EstadoActividad.noEntregada => 'no entregada',
      EstadoActividad.presentado => 'presentado',
      _ => 'entregada',
    };
    final cuando = actividad.completadaEn ?? actividad.fechaLimite;
    return '$materia · $texto ${fechaCorta(cuando, ahora).split(' ').first}';
  }
  if (actividad.estaVencida(ahora)) return '$materia · ${vencio(actividad.fechaLimite, ahora)}';
  return '$materia · ${fechaCorta(actividad.fechaLimite, ahora)}';
}

/// "INTU", "Correo", "En clase", "WhatsApp".
String canalTexto(CanalEntrega canal) => switch (canal) {
  CanalEntrega.intu => 'INTU',
  CanalEntrega.correo => 'Correo',
  CanalEntrega.enClase => 'En clase',
  CanalEntrega.whatsapp => 'WhatsApp',
};

/// "15 %", "12,5 %".
String porcentajeTexto(double valor) {
  final texto = valor == valor.roundToDouble() ? valor.toStringAsFixed(0) : valor.toString().replaceAll('.', ',');
  return '$texto %';
}

/// "Proyecto · 15 %". Nulo si no cuenta para la nota.
String? parteDeLaNota(Actividad actividad) {
  if (actividad.porcentaje <= 0) return null;
  final porcentaje = porcentajeTexto(actividad.porcentaje);
  final componente = actividad.componenteNombre;
  return componente == null ? porcentaje : '$componente · $porcentaje';
}

/// Lo que dice S1 al completar: "2 días antes de la fecha límite.". Nulo si
/// se completó tarde (entonces S1 usa su texto general).
String? mensajeATiempo(DateTime fechaLimite, DateTime completadaEn) {
  if (completadaEn.isAfter(fechaLimite)) return null;
  return switch (diasEntre(completadaEn, fechaLimite)) {
    0 => 'Antes de la fecha límite.',
    1 => 'Un día antes de la fecha límite.',
    final dias => '$dias días antes de la fecha límite.',
  };
}

/// Título de un bloque de estudio en el detalle: "Estudiar para Parcial 2".
String tituloBloque(Actividad actividad) =>
    actividad.esExamen ? 'Estudiar para ${actividad.titulo}' : 'Avanzar en ${actividad.titulo}';

/// Bloques que se muestran en el detalle: pendientes y hechos (los
/// cancelados o descartados ya no cuentan).
List<BloqueEstudio> bloquesVisibles(List<BloqueEstudio> bloques) => bloques
    .where((bloque) => bloque.estado == EstadoBloque.pendiente || bloque.estado == EstadoBloque.completado)
    .toList();
