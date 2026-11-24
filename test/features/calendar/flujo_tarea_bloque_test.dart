import 'package:flutter_test/flutter_test.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/features/calendar/calendar_di.dart';
import 'package:studyflow/features/calendar/domain/agenda_del_dia.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/calendar/domain/horario_materia.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_bloc.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_event.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_state.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';
import 'package:studyflow/features/study_blocks/study_blocks_di.dart';
import 'package:studyflow/features/study_blocks/ui/bloc/new_study_block_cubit.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';
import 'package:studyflow/features/task_form/task_form_di.dart';
import 'package:studyflow/features/task_form/ui/bloc/task_form_cubit.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form_data.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import 'fixtures.dart';

const _proyecto = ComponenteNota(
  id: 'c1',
  materiaId: 'm1',
  nombre: 'Proyecto',
  porcentaje: 40,
);
const _moviles = Materia(
  id: 'm1',
  periodoId: 'p1',
  nombre: 'Aplicaciones Móviles',
  creditos: 3,
  colorHex: '#A78BFA',
  componentes: [_proyecto],
);

/// Una "base de datos" en memoria con las tablas actividades y
/// bloques_estudio. Hace de los tres repositorios a la vez, así lo que guarda
/// el formulario o Nuevo bloque es lo mismo que luego lee el calendario.
class _BaseEnMemoria
    implements TaskFormRepository, CalendarRepository, StudyBlocksRepository {
  final actividades = <Actividad>[];
  final bloques = <BloqueEstudio>[];

  bool _entre(DateTime t, DateTime desde, DateTime hasta) =>
      !t.isBefore(desde) && t.isBefore(hasta);

  // --- Formulario de tarea ---
  @override
  Future<List<Materia>> materiasConComponentes() async => [_moviles];

  @override
  Future<List<PorcentajeAsignado>> porcentajesAsignados() async => [
    for (final a in actividades)
      (
        actividadId: a.id,
        componenteId: a.componenteId,
        porcentaje: a.porcentaje,
      ),
  ];

  @override
  Future<Actividad> crearActividad(Actividad actividad) async {
    final guardada = Actividad(
      id: 'a${actividades.length + 1}',
      componenteId: actividad.componenteId,
      titulo: actividad.titulo,
      tipo: actividad.tipo,
      fechaLimite: actividad.fechaLimite,
      porcentaje: actividad.porcentaje,
      prioridad: actividad.prioridad,
      estado: actividad.estado,
      recordatorio: actividad.recordatorio,
      creadoEn: actividad.creadoEn,
      actualizadoEn: actividad.actualizadoEn,
      canalEntrega: actividad.canalEntrega,
    );
    actividades.add(guardada);
    return guardada;
  }

  @override
  Future<Actividad> editarActividad(
    Actividad actividad, {
    required bool cambiarEstado,
  }) async => actividad;

  // --- Calendario ---
  @override
  Future<List<HorarioMateria>> horarios() async => [];

  @override
  Future<List<Actividad>> actividadesEntre(
    DateTime desde,
    DateTime hasta,
  ) async => [
    for (final a in actividades)
      if (_entre(a.fechaLimite, desde, hasta)) a,
  ];

  @override
  Future<List<BloqueEstudio>> bloquesEntre(
    DateTime desde,
    DateTime hasta,
  ) async => [
    for (final b in bloques)
      if (_entre(b.inicio, desde, hasta)) b,
  ];

  // --- Bloques de estudio ---
  @override
  Future<BloqueEstudio> crearBloque(BloqueEstudio bloque) async {
    final guardado = BloqueEstudio(
      id: 'b${bloques.length + 1}',
      actividadId: bloque.actividadId,
      inicio: bloque.inicio,
      fin: bloque.fin,
      estado: bloque.estado,
      avisoMin: bloque.avisoMin,
    );
    bloques.add(guardado);
    return guardado;
  }

  @override
  Future<List<Actividad>> actividadesAbiertas() async => actividades;

  @override
  Future<Actividad> actividad(String id) async =>
      actividades.firstWhere((a) => a.id == id);

  @override
  Future<List<BloqueEstudio>> bloquesDeLaActividad(String actividadId) async =>
      bloques.where((b) => b.actividadId == actividadId).toList();

  @override
  Future<EstadoActividad> estadoDeActividad(String actividadId) async =>
      (await actividad(actividadId)).estado;

  @override
  Future<void> completarBloque(String id) async {}

  @override
  Future<void> descartarBloque(String id) async {}

  @override
  Future<void> marcarActividadEnProgreso(String actividadId) async {}

  @override
  Future<void> reprogramarBloque(
    String id,
    DateTime inicio,
    DateTime fin,
  ) async {}
}

/// Flujo completo con las piezas reales de GetIt y una base en memoria:
/// crear tarea → sale en el calendario → crear bloque → sale el bloque.
void main() {
  late _BaseEnMemoria base;

  setUp(() async {
    await sl.reset();
    registrarTaskForm(sl);
    registrarCalendar(sl);
    registrarStudyBlocks(sl);

    base = _BaseEnMemoria();
    await sl.unregister<TaskFormRepository>();
    await sl.unregister<CalendarRepository>();
    await sl.unregister<StudyBlocksRepository>();
    sl.registerSingleton<TaskFormRepository>(base);
    sl.registerSingleton<CalendarRepository>(base);
    sl.registerSingleton<StudyBlocksRepository>(base);
  });

  tearDown(() => sl.reset());

  /// Espera a que el calendario termine de cargar y devuelve la agenda del día.
  Future<List<EntradaAgenda>> agendaTrasRecargar(
    CalendarBloc calendario,
  ) async {
    calendario.add(const CalendarioRecargado());
    await calendario.stream.firstWhere((s) => s.status == CalendarStatus.listo);
    // Deja pasar la emisión para leer el estado final.
    await Future<void>.delayed(Duration.zero);
    return calendario.state.agenda;
  }

  test(
    'crear tarea → sale en el calendario → crear bloque → sale el bloque',
    () async {
      // El calendario abierto en el martes 10 de noviembre.
      final calendario = CalendarBloc(
        sl(),
        sl(),
        completar: sl(),
        ahora: () => DateTime(martes.year, martes.month, martes.day, 8),
      )..add(const CalendarioIniciado());
      await calendario.stream.firstWhere(
        (s) => s.status == CalendarStatus.listo,
      );
      expect(calendario.state.agenda, isEmpty);

      // 1. Nueva tarea para el martes, con porcentaje decimal.
      final formulario = sl<TaskFormCubit>();
      await formulario.cargar();
      await formulario.guardar(
        TaskFormData(
          title: 'Taller 3: consultas SQL',
          materia: _moviles,
          componente: _proyecto,
          date: martes,
          time: const TimeOfDay(hour: 18, minute: 0),
          porcentaje: 12.5,
          canal: CanalEntrega.intu,
        ),
      );
      final tarea = formulario.state.guardada!;
      expect(tarea.porcentaje, 12.5);

      // 2. La tarea sale en el calendario de ese día.
      var agenda = await agendaTrasRecargar(calendario);
      expect(
        agenda.whereType<EntregaEnAgenda>().map((e) => e.actividad.titulo),
        ['Taller 3: consultas SQL'],
      );

      // 3. Nuevo bloque para preparar esa tarea, el martes de 2 a 3 p. m.
      final nuevoBloque = sl<NewStudyBlockCubit>();
      await nuevoBloque.cargar();
      expect(nuevoBloque.state.actividades.map((a) => a.id), [tarea.id]);
      await nuevoBloque.guardar(
        inicio: DateTime(martes.year, martes.month, martes.day, 14),
        minutos: 60,
        actividadId: tarea.id,
      );
      expect(nuevoBloque.state.guardado, isTrue);

      // 4. El bloque sale en el calendario junto a la entrega.
      agenda = await agendaTrasRecargar(calendario);
      final bloques = agenda.whereType<BloqueEnAgenda>().toList();
      expect(bloques, hasLength(1));
      expect(bloques.single.bloque.actividadId, tarea.id);
      expect(bloques.single.bloque.inicio.hour, 14);
      expect(agenda.whereType<EntregaEnAgenda>(), hasLength(1));

      await formulario.close();
      await nuevoBloque.close();
      await calendario.close();
    },
  );
}
