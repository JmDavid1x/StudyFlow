import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/assistant/domain/textos_asistente.dart';

/// Una actividad dentro del orden sugerido.
class ItemOrden extends Equatable {
  const ItemOrden({
    required this.actividad,
    required this.orden,
    required this.motivo,
    required this.horasSugeridas,
  });

  final Actividad actividad;

  /// 1 = hacer primero.
  final int orden;

  /// "Vence hoy a las 6:00 p. m." o "Vale 30 % de la nota".
  final String motivo;
  final double horasSugeridas;

  @override
  List<Object?> get props => [actividad.id, orden, motivo, horasSugeridas];
}

/// Orden de respaldo: el que usa el asistente cuando la IA no responde (y en
/// el Sprint 2, siempre). No gasta consultas del plan gratis.
///
/// De las actividades sin cerrar:
/// 1. la que vence primero (por día de calendario);
/// 2. si vencen el mismo día, la que vale más porcentaje;
/// 3. si empatan, la de mayor prioridad (alta, media, baja);
/// 4. si aún empatan, la que vence más temprano ese día.
List<ItemOrden> ordenDeRespaldo(
  Iterable<Actividad> actividades,
  DateTime ahora,
) {
  final abiertas = actividades.where((a) => !a.estado.estaCerrada).toList()
    ..sort(_compararActividades);
  return [
    for (final (indice, actividad) in abiertas.indexed)
      ItemOrden(
        actividad: actividad,
        orden: indice + 1,
        motivo: motivoDe(actividad, ahora),
        horasSugeridas: horasSugeridas(actividad.tipo),
      ),
  ];
}

int _compararActividades(Actividad a, Actividad b) {
  final porDia = soloDia(a.fechaLimite).compareTo(soloDia(b.fechaLimite));
  if (porDia != 0) return porDia;
  final porPorcentaje = b.porcentaje.compareTo(a.porcentaje);
  if (porPorcentaje != 0) return porPorcentaje;
  final porPrioridad = b.prioridad.index.compareTo(a.prioridad.index);
  if (porPrioridad != 0) return porPrioridad;
  return a.fechaLimite.compareTo(b.fechaLimite);
}

/// Horas de estudio sugeridas por tipo: examen y proyecto 2, tarea 1.
double horasSugeridas(TipoActividad tipo) => switch (tipo) {
  TipoActividad.examen || TipoActividad.proyecto => 2.0,
  TipoActividad.tarea => 1.0,
};

/// Por qué va en ese lugar, en una frase:
/// - venció o vence hoy o mañana: "Vence hoy a las 6:00 p. m.";
/// - si no, si cuenta en la nota: "Vale 30 % de la nota";
/// - si no: "Vence el jue 12 nov".
String motivoDe(Actividad actividad, DateTime ahora) {
  final fecha = actividad.fechaLimite;
  final verbo = actividad.esExamen ? 'Es' : 'Vence';
  if (fecha.isBefore(ahora)) {
    return '${actividad.esExamen ? 'Fue' : 'Venció'} el ${textoDia(fecha)} a las ${textoHora(fecha)}';
  }
  switch (diasEntre(ahora, fecha)) {
    case 0:
      return '$verbo hoy a las ${textoHora(fecha)}';
    case 1:
      return '$verbo mañana a las ${textoHora(fecha)}';
  }
  if (actividad.porcentaje > 0) {
    return 'Vale ${textoPorcentaje(actividad.porcentaje)} de la nota';
  }
  return '$verbo el ${textoDia(fecha)}';
}

/// Texto que se guarda como respuesta del asistente en mensajes_asistente.
/// La primera línea es la que se ve en la burbuja; el resto, la lista.
String respuestaDeRespaldo(
  List<ItemOrden> orden, {
  required bool sinConsultas,
}) {
  if (orden.isEmpty) {
    return 'No tienes actividades pendientes en tu semestre. Agrega una tarea y vuelve a preguntarme.';
  }
  final intro = sinConsultas
      ? 'Ya usaste tus consultas gratis de esta semana, así que te dejo el orden de respaldo.'
      : 'No pude responderte con la IA, así que te dejo el orden de respaldo.';
  final lineas = [
    for (final item in orden)
      '${item.orden}. ${item.actividad.titulo}: ${item.motivo}',
  ];
  return [intro, ...lineas].join('\n');
}

/// Resumen del plan para planes_estudio ("Tu plan de hoy" en Inicio).
String resumenDelPlan(List<ItemOrden> orden) {
  if (orden.isEmpty) return 'Sin actividades pendientes.';
  final primera = orden.first.actividad.titulo;
  if (orden.length == 1) return 'Empieza por $primera.';
  return 'Empieza por $primera y sigue con ${orden.length - 1} ${orden.length == 2 ? 'actividad más' : 'actividades más'}.';
}
