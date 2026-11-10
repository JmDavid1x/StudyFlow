import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subjects/domain/actividad_con_nota.dart';

Materia materiaDePrueba({
  String id = 'm1',
  String nombre = 'Bases de Datos',
  int creditos = 3,
  double? meta = 4.0,
  List<ComponenteNota> componentes = const [],
  List<HorarioClase> horarios = const [],
}) => Materia(
  id: id,
  periodoId: 'p1',
  nombre: nombre,
  creditos: creditos,
  colorHex: '#A78BFA',
  metaNota: meta,
  componentes: componentes,
  horarios: horarios,
);

ComponenteNota componenteDePrueba(
  String id, {
  String materiaId = 'm1',
  String nombre = 'Talleres',
  double porcentaje = 50,
}) => ComponenteNota(
  id: id,
  materiaId: materiaId,
  nombre: nombre,
  porcentaje: porcentaje,
);

/// Actividad que vale [porcentaje] %, con nota si se pasa [nota].
ActividadConNota actividadDePrueba(
  String id, {
  String componenteId = 'c1',
  double porcentaje = 10,
  double? nota,
}) {
  final fecha = DateTime(2026, 11, 10, 12);
  return ActividadConNota(
    actividad: Actividad(
      id: id,
      componenteId: componenteId,
      titulo: 'Actividad $id',
      tipo: TipoActividad.tarea,
      fechaLimite: fecha,
      porcentaje: porcentaje,
      prioridad: Prioridad.media,
      estado: EstadoActividad.porHacer,
      recordatorio: false,
      creadoEn: fecha,
      actualizadoEn: fecha,
    ),
    calificacion: nota == null
        ? null
        : Calificacion(
            id: 'cal-$id',
            actividadId: id,
            nota: nota,
            registradaEn: fecha,
          ),
  );
}
