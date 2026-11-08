import 'package:studyflow/core/data/data.dart';

/// Actividad mínima para los tests (solo cambia lo que importa en cada caso).
Actividad actividad(
  String id, {
  required DateTime fecha,
  TipoActividad tipo = TipoActividad.tarea,
  EstadoActividad? estado,
  Prioridad prioridad = Prioridad.media,
  DateTime? completadaEn,
}) => Actividad(
  id: id,
  componenteId: 'c1',
  titulo: 'Actividad $id',
  tipo: tipo,
  fechaLimite: fecha,
  porcentaje: 10,
  prioridad: prioridad,
  estado: estado ?? (tipo == TipoActividad.examen ? EstadoActividad.pendiente : EstadoActividad.porHacer),
  recordatorio: true,
  creadoEn: DateTime(2026, 11, 1),
  actualizadoEn: DateTime(2026, 11, 1),
  completadaEn: completadaEn,
);

BloqueEstudio bloque(
  String id, {
  required DateTime inicio,
  Duration duracion = const Duration(hours: 1),
  EstadoBloque estado = EstadoBloque.pendiente,
  String actividadId = 'a1',
}) => BloqueEstudio(id: id, actividadId: actividadId, inicio: inicio, fin: inicio.add(duracion), estado: estado);

Notificacion notificacion(String id, {required DateTime programadaPara, DateTime? leidaEn}) => Notificacion(
  id: id,
  perfilId: 'p1',
  tipo: TipoNotificacion.entregaHoy,
  titulo: 'Aviso $id',
  cuerpo: 'Cuerpo',
  programadaPara: programadaPara,
  leidaEn: leidaEn,
);
