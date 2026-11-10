import 'package:studyflow/core/data/data.dart';

/// Actividad mínima para los tests (solo cambia lo que importa en cada caso).
Actividad actividad(
  String id, {
  required DateTime fecha,
  TipoActividad tipo = TipoActividad.tarea,
  EstadoActividad? estado,
  Prioridad prioridad = Prioridad.media,
  double porcentaje = 10,
}) => Actividad(
  id: id,
  componenteId: 'c1',
  titulo: 'Actividad $id',
  tipo: tipo,
  fechaLimite: fecha,
  porcentaje: porcentaje,
  prioridad: prioridad,
  estado:
      estado ??
      (tipo == TipoActividad.examen
          ? EstadoActividad.pendiente
          : EstadoActividad.porHacer),
  recordatorio: true,
  creadoEn: DateTime(2026, 11, 1),
  actualizadoEn: DateTime(2026, 11, 1),
);

MensajeAsistente mensaje(
  String id, {
  required DateTime creadoEn,
  RolMensaje rol = RolMensaje.asistente,
  bool usadoRespaldo = false,
  String contenido = 'Hola',
}) => MensajeAsistente(
  id: id,
  perfilId: 'p1',
  rol: rol,
  contenido: contenido,
  usadoRespaldo: usadoRespaldo,
  creadoEn: creadoEn,
);

/// Clase de [dia] (1 = lunes) entre [desde] y [hasta] horas.
HorarioClase clase(int dia, int desde, int hasta) => HorarioClase(
  id: 'h$dia$desde',
  materiaId: 'm1',
  diaSemana: dia,
  horaInicio: Hora(desde, 0),
  horaFin: Hora(hasta, 0),
);

BloqueEstudio bloque(
  String id, {
  required DateTime inicio,
  Duration duracion = const Duration(hours: 1),
  String? planId,
}) => BloqueEstudio(
  id: id,
  actividadId: 'otra',
  planId: planId,
  inicio: inicio,
  fin: inicio.add(duracion),
  estado: EstadoBloque.pendiente,
);

Suscripcion suscripcion({
  EstadoSuscripcion estado = EstadoSuscripcion.enPrueba,
}) => Suscripcion(
  id: 's1',
  perfilId: 'p1',
  periodicidad: Periodicidad.mensual,
  precioCop: 9900,
  estado: estado,
  iniciaEn: DateTime(2026, 11, 10),
  pruebaHasta: DateTime(2026, 11, 17),
  renovacionAutomatica: true,
);
