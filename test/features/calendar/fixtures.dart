import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/calendar/domain/horario_materia.dart';

// Datos de prueba con fechas fijas. El lunes 9 de noviembre de 2026 es lunes.
final lunes = DateTime(2026, 11, 9);
final martes = DateTime(2026, 11, 10);

/// Clase de [materia] el [dia] de la semana (1 = lunes) de [desde] a [hasta].
HorarioMateria clase(String materia, int dia, Hora desde, Hora hasta) {
  final horario = HorarioClase(
    id: 'h-$materia-$dia',
    materiaId: 'm-$materia',
    diaSemana: dia,
    horaInicio: desde,
    horaFin: hasta,
  );
  return HorarioMateria(
    horario: horario,
    materia: Materia(
      id: 'm-$materia',
      periodoId: 'p1',
      nombre: materia,
      creditos: 3,
      colorHex: '#2DD4BF',
      horarios: [horario],
    ),
  );
}

Actividad actividad(
  String id, {
  required DateTime fecha,
  TipoActividad tipo = TipoActividad.tarea,
  EstadoActividad estado = EstadoActividad.porHacer,
}) => Actividad(
  id: id,
  componenteId: 'c1',
  titulo: 'Actividad $id',
  tipo: tipo,
  fechaLimite: fecha,
  porcentaje: 10,
  prioridad: Prioridad.media,
  estado: estado,
  recordatorio: true,
  creadoEn: DateTime(2026, 11, 1),
  actualizadoEn: DateTime(2026, 11, 1),
  canalEntrega: tipo == TipoActividad.examen ? null : CanalEntrega.intu,
);

BloqueEstudio bloque(
  String id, {
  required DateTime inicio,
  required DateTime fin,
  EstadoBloque estado = EstadoBloque.pendiente,
  String actividadId = 'a1',
}) => BloqueEstudio(
  id: id,
  actividadId: actividadId,
  inicio: inicio,
  fin: fin,
  estado: estado,
  actividadTitulo: 'Taller $id',
);
