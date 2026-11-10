import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/tasks/domain/filtros_tareas.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';
import 'package:studyflow/features/tasks/ui/bloc/tasks_bloc.dart';

import 'fixtures.dart';

class _MockTasksRepository extends Mock implements TasksRepository {}

void main() {
  late _MockTasksRepository repositorio;
  final ahora = DateTime(2026, 11, 11, 10);
  final vencida = actividad('v', fecha: DateTime(2026, 11, 10, 10));
  final deHoy = actividad('h', fecha: DateTime(2026, 11, 11, 20));
  final deSemana = actividad('s', fecha: DateTime(2026, 11, 13, 10));
  final hecha = actividad('c', fecha: DateTime(2026, 11, 9), estado: EstadoActividad.completada);
  final examen = actividad('e', fecha: DateTime(2026, 11, 12, 8), tipo: TipoActividad.examen);

  final cargando = isA<TasksState>().having((s) => s.estado, 'estado', EstadoTareas.cargando);

  TasksBloc crear() => TasksBloc(repositorio, reloj: () => ahora);

  setUp(() {
    repositorio = _MockTasksRepository();
    when(() => repositorio.actividadesDelPeriodo()).thenAnswer((_) async => [vencida, deHoy, deSemana, hecha]);
    when(() => repositorio.completar(any())).thenAnswer((_) async {});
    when(() => repositorio.marcarPresentado(any())).thenAnswer((_) async {});
  });

  blocTest<TasksBloc, TasksState>(
    'carga y reparte en secciones',
    build: crear,
    act: (bloc) => bloc.add(const TareasPedidas()),
    expect: () => [
      cargando,
      isA<TasksState>().having((s) => s.estado, 'estado', EstadoTareas.listo).having(
        (s) => s.secciones.map((x) => x.titulo).toList(),
        'secciones',
        ['Vencidas', 'Hoy', 'Esta semana', 'Completadas'],
      ),
    ],
  );

  blocTest<TasksBloc, TasksState>(
    'sin actividades queda vacío',
    setUp: () => when(() => repositorio.actividadesDelPeriodo()).thenAnswer((_) async => []),
    build: crear,
    act: (bloc) => bloc.add(const TareasPedidas()),
    expect: () => [cargando, isA<TasksState>().having((s) => s.estado, 'estado', EstadoTareas.vacio)],
  );

  blocTest<TasksBloc, TasksState>(
    'si la primera carga falla queda en error con el mensaje',
    setUp: () => when(() => repositorio.actividadesDelPeriodo()).thenThrow(const AppException('Sin conexión.')),
    build: crear,
    act: (bloc) => bloc.add(const TareasPedidas()),
    expect: () => [
      cargando,
      isA<TasksState>()
          .having((s) => s.estado, 'estado', EstadoTareas.error)
          .having((s) => s.mensaje, 'mensaje', 'Sin conexión.'),
    ],
  );

  blocTest<TasksBloc, TasksState>(
    'el chip Hoy muestra vencidas y hoy; Completadas solo las cerradas',
    build: crear,
    act: (bloc) async {
      bloc.add(const TareasPedidas());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const FiltroCambiado(FiltroTareas.hoy));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const FiltroCambiado(FiltroTareas.completadas));
    },
    skip: 2,
    expect: () => [
      isA<TasksState>().having((s) => s.secciones.map((x) => x.titulo).toList(), 'hoy', ['Vencidas', 'Hoy']),
      isA<TasksState>().having((s) => s.secciones.map((x) => x.titulo).toList(), 'completadas', ['Completadas']),
    ],
  );

  blocTest<TasksBloc, TasksState>(
    'el círculo completa una tarea y recarga',
    build: crear,
    act: (bloc) => bloc.add(CirculoTocado(deHoy)),
    verify: (_) {
      verify(() => repositorio.completar('h')).called(1);
      verify(() => repositorio.actividadesDelPeriodo()).called(1);
    },
  );

  blocTest<TasksBloc, TasksState>(
    'el círculo de un examen lo marca como presentado',
    build: crear,
    act: (bloc) => bloc.add(CirculoTocado(examen)),
    verify: (_) => verify(() => repositorio.marcarPresentado('e')).called(1),
  );

  blocTest<TasksBloc, TasksState>(
    'si la acción falla avisa y no recarga',
    setUp: () => when(() => repositorio.completar(any())).thenThrow(const AppException('No pudimos guardar.')),
    build: crear,
    act: (bloc) => bloc.add(CirculoTocado(deHoy)),
    expect: () => [
      isA<TasksState>().having((s) => s.aviso, 'aviso', 'No pudimos guardar.').having((s) => s.avisoId, 'id', 1),
    ],
    verify: (_) => verifyNever(() => repositorio.actividadesDelPeriodo()),
  );
}
