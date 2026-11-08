import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/tasks/domain/filtros_tareas.dart';

import 'fixtures.dart';

void main() {
  // Miércoles 11 de noviembre de 2026, 10:00 a. m.
  final ahora = DateTime(2026, 11, 11, 10);

  final vencidaAyer = actividad('vencida-ayer', fecha: DateTime(2026, 11, 10, 23, 59));
  final vencidaHoyTemprano = actividad('vencida-hoy', fecha: DateTime(2026, 11, 11, 8));
  final hoyNoche = actividad('hoy-noche', fecha: DateTime(2026, 11, 11, 23, 59));
  final jueves = actividad('jueves', fecha: DateTime(2026, 11, 12, 18));
  final domingo = actividad('domingo', fecha: DateTime(2026, 11, 15, 23, 59));
  final lunesSiguiente = actividad('lunes-sig', fecha: DateTime(2026, 11, 16, 8));
  final completada = actividad(
    'completada',
    fecha: DateTime(2026, 11, 13),
    estado: EstadoActividad.completada,
    completadaEn: DateTime(2026, 11, 10, 20),
  );
  final noEntregada = actividad('no-entregada', fecha: DateTime(2026, 11, 2), estado: EstadoActividad.noEntregada);
  final examenPresentado = actividad(
    'examen-presentado',
    tipo: TipoActividad.examen,
    fecha: DateTime(2026, 11, 9, 7),
    estado: EstadoActividad.presentado,
  );
  final examenJueves = actividad('examen-jueves', tipo: TipoActividad.examen, fecha: DateTime(2026, 11, 12, 7));

  final todas = [
    domingo,
    completada,
    lunesSiguiente,
    vencidaAyer,
    hoyNoche,
    noEntregada,
    jueves,
    examenPresentado,
    vencidaHoyTemprano,
    examenJueves,
  ];

  List<String> ids(List<Actividad> lista) => [for (final a in lista) a.id];

  test('cada actividad cae en una sola sección', () {
    final grupos = agruparTareas(todas, ahora);
    expect(ids(grupos.vencidas), ['vencida-ayer', 'vencida-hoy']);
    expect(ids(grupos.hoy), ['hoy-noche']);
    expect(ids(grupos.semana), ['examen-jueves', 'jueves', 'domingo']);
    expect(ids(grupos.masAdelante), ['lunes-sig']);
    expect(grupos.de(FiltroTareas.todas), hasLength(todas.length));
  });

  test('completadas incluye las cerradas, la más reciente primero', () {
    final grupos = agruparTareas(todas, ahora);
    // completada (cerró el 10), examen presentado (fecha el 9), no entregada (fecha el 2).
    expect(ids(grupos.completadas), ['completada', 'examen-presentado', 'no-entregada']);
  });

  test('una cerrada nunca sale como vencida aunque ya pasó la fecha', () {
    final grupos = agruparTareas([noEntregada, examenPresentado], ahora);
    expect(grupos.vencidas, isEmpty);
    expect(grupos.completadas, hasLength(2));
  });

  test('el estado vencida guardado en la base también cuenta como vencida', () {
    final guardada = actividad('guardada', fecha: DateTime(2026, 11, 20), estado: EstadoActividad.vencida);
    expect(ids(agruparTareas([guardada], ahora).vencidas), ['guardada']);
  });

  test('una tarea en progreso que vence hoy más tarde está en Hoy', () {
    final enProgreso = actividad('en-progreso', fecha: DateTime(2026, 11, 11, 18), estado: EstadoActividad.enProgreso);
    expect(ids(agruparTareas([enProgreso], ahora).hoy), ['en-progreso']);
  });

  test('el domingo "Esta semana" queda vacía y el lunes ya es otra semana', () {
    final domingoNoche = DateTime(2026, 11, 15, 20);
    final grupos = agruparTareas([domingo, lunesSiguiente], domingoNoche);
    expect(ids(grupos.hoy), ['domingo']);
    expect(grupos.semana, isEmpty);
    expect(ids(grupos.masAdelante), ['lunes-sig']);
  });

  test('cada chip devuelve su sección', () {
    final grupos = agruparTareas(todas, ahora);
    expect(grupos.de(FiltroTareas.vencidas), grupos.vencidas);
    expect(grupos.de(FiltroTareas.hoy), grupos.hoy);
    expect(grupos.de(FiltroTareas.semana), grupos.semana);
    expect(grupos.de(FiltroTareas.completadas), grupos.completadas);
  });

  test('sin actividades está vacía', () {
    expect(agruparTareas(const [], ahora).estaVacia, isTrue);
    expect(agruparTareas(todas, ahora).estaVacia, isFalse);
  });
}
