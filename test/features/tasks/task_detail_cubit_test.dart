import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';
import 'package:studyflow/features/tasks/ui/bloc/task_detail_cubit.dart';

import 'fixtures.dart';

class _MockTasksRepository extends Mock implements TasksRepository {}

/// Actividad con materia (para el progreso de S1).
Actividad deMateria(String id, {required DateTime fecha, EstadoActividad estado = EstadoActividad.porHacer}) =>
    Actividad(
      id: id,
      componenteId: 'c1',
      titulo: 'Actividad $id',
      tipo: TipoActividad.tarea,
      fechaLimite: fecha,
      porcentaje: 10,
      prioridad: Prioridad.media,
      estado: estado,
      recordatorio: true,
      creadoEn: DateTime(2026, 11, 1),
      actualizadoEn: DateTime(2026, 11, 1),
      materiaId: 'm1',
      materiaNombre: 'Bases de Datos',
    );

void main() {
  late _MockTasksRepository repositorio;
  final ahora = DateTime(2026, 11, 11, 10);
  final tarea = deMateria('a1', fecha: DateTime(2026, 11, 13, 23, 59));
  final otra = deMateria('a2', fecha: DateTime(2026, 11, 5), estado: EstadoActividad.completada);
  final pendiente = bloque('b1', inicio: DateTime(2026, 11, 12, 10), actividadId: 'a1');
  final hecho = bloque('b2', inicio: DateTime(2026, 11, 10, 10), actividadId: 'a1', estado: EstadoBloque.completado);
  final cancelado = bloque('b3', inicio: DateTime(2026, 11, 9, 10), actividadId: 'a1', estado: EstadoBloque.cancelado);

  TaskDetailCubit crear([Actividad? actividad]) => TaskDetailCubit(repositorio, actividad ?? tarea, reloj: () => ahora);

  setUp(() {
    repositorio = _MockTasksRepository();
    when(() => repositorio.bloquesDeActividad(any())).thenAnswer((_) async => [hecho, pendiente, cancelado]);
    when(() => repositorio.actividadesDelPeriodo()).thenAnswer((_) async => [tarea, otra]);
    when(() => repositorio.actividadPorId(any())).thenAnswer((_) async => tarea);
    when(() => repositorio.completar(any())).thenAnswer((_) async {});
    when(() => repositorio.marcarNoEntregada(any())).thenAnswer((_) async {});
    when(() => repositorio.eliminar(any())).thenAnswer((_) async {});
  });

  blocTest<TaskDetailCubit, TaskDetailState>(
    'carga los bloques sin los cancelados',
    build: crear,
    act: (cubit) => cubit.cargarBloques(),
    expect: () => [
      isA<TaskDetailState>().having((s) => s.cargandoBloques, 'cargando', false).having(
        (s) => s.bloques.map((b) => b.id).toList(),
        'bloques',
        ['b2', 'b1'],
      ),
    ],
  );

  blocTest<TaskDetailCubit, TaskDetailState>(
    'completar arma el resumen de S1: a tiempo, progreso y bloque quitado',
    build: crear,
    act: (cubit) async {
      await cubit.cargarBloques();
      await cubit.completar();
    },
    verify: (cubit) {
      final s = cubit.state;
      expect(s.resultado, ResultadoDetalle.completada);
      expect(s.cambio, isTrue);
      expect(s.ocupado, isFalse);
      expect(s.actividad.estado, EstadoActividad.completada);
      expect(s.resumen!.aTiempo, '2 días antes de la fecha límite.');
      expect((s.resumen!.hechas, s.resumen!.total), (2, 2));
      expect(s.resumen!.bloquesQuitados.map((b) => b.id), ['b1']);
      expect(s.bloques.map((b) => b.id), ['b2']);
      verify(() => repositorio.completar('a1')).called(1);
    },
  );

  blocTest<TaskDetailCubit, TaskDetailState>(
    'si el progreso de la materia falla, S1 sale sin barra',
    setUp: () => when(() => repositorio.actividadesDelPeriodo()).thenThrow(const AppException('x')),
    build: crear,
    act: (cubit) => cubit.completar(),
    verify: (cubit) {
      expect(cubit.state.resultado, ResultadoDetalle.completada);
      expect(cubit.state.resumen!.hechas, isNull);
    },
  );

  blocTest<TaskDetailCubit, TaskDetailState>(
    'no entregada solo en una vencida',
    build: () => crear(deMateria('a3', fecha: DateTime(2026, 11, 10))),
    act: (cubit) => cubit.marcarNoEntregada(),
    verify: (cubit) {
      expect(cubit.state.actividad.estado, EstadoActividad.noEntregada);
      verify(() => repositorio.marcarNoEntregada('a3')).called(1);
    },
  );

  blocTest<TaskDetailCubit, TaskDetailState>(
    'una regla que no se cumple avisa y no guarda',
    build: crear,
    act: (cubit) => cubit.marcarNoEntregada(),
    verify: (cubit) {
      expect(cubit.state.avisoId, 1);
      expect(cubit.state.aviso, 'Solo puedes marcar como no entregada una tarea vencida.');
      expect(cubit.state.ocupado, isFalse);
      verifyNever(() => repositorio.marcarNoEntregada(any()));
    },
  );

  blocTest<TaskDetailCubit, TaskDetailState>(
    'eliminar deja el resultado eliminada',
    build: crear,
    act: (cubit) => cubit.eliminar(),
    verify: (cubit) {
      expect(cubit.state.resultado, ResultadoDetalle.eliminada);
      verify(() => repositorio.eliminar('a1')).called(1);
    },
  );

  blocTest<TaskDetailCubit, TaskDetailState>(
    'recargar trae la actividad editada; si ya no existe, se cierra',
    setUp: () => when(() => repositorio.actividadPorId(any())).thenAnswer((_) async => null),
    build: crear,
    act: (cubit) => cubit.recargar(),
    verify: (cubit) => expect(cubit.state.resultado, ResultadoDetalle.eliminada),
  );
}
