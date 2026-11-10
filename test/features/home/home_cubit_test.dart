import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/home/domain/home_repository.dart';
import 'package:studyflow/features/home/ui/bloc/home_cubit.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';

import '../tasks/fixtures.dart';

class _MockHomeRepository extends Mock implements HomeRepository {}

class _MockTasksRepository extends Mock implements TasksRepository {}

void main() {
  late _MockHomeRepository inicio;
  late _MockTasksRepository tareas;
  final ahora = DateTime(2026, 11, 11, 10);
  final perfil = Perfil(
    id: 'p1',
    universidadId: 'u1',
    nombre: 'Santiago Pérez',
    correo: 's@u.edu.co',
    configuracionCompleta: true,
    creadoEn: DateTime(2026, 11, 1),
  );
  final deHoy = actividad('h', fecha: DateTime(2026, 11, 11, 20), prioridad: Prioridad.alta);
  final manana = actividad('m', fecha: DateTime(2026, 11, 12, 20));
  final examen = actividad('e', fecha: DateTime(2026, 11, 13, 8), tipo: TipoActividad.examen);

  HomeCubit crear() => HomeCubit(inicio, tareas, reloj: () => ahora);

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() {
    inicio = _MockHomeRepository();
    tareas = _MockTasksRepository();
    when(() => inicio.perfil()).thenAnswer((_) async => perfil);
    when(() => inicio.actividadesEntre(any(), any())).thenAnswer((_) async => [deHoy, manana, examen]);
    when(() => inicio.bloquesEntre(any(), any())).thenAnswer((_) async => []);
    when(
      () => inicio.notificaciones(),
    ).thenAnswer((_) async => [notificacion('n1', programadaPara: DateTime(2026, 11, 11, 7))]);
    when(() => tareas.completar(any())).thenAnswer((_) async {});
    when(() => tareas.marcarPresentado(any())).thenAnswer((_) async {});
  });

  blocTest<HomeCubit, HomeState>(
    'carga el saludo y el resumen de la semana',
    build: crear,
    act: (cubit) => cubit.cargar(),
    expect: () => [
      isA<HomeState>().having((s) => s.estado, 'estado', EstadoInicio.cargando),
      isA<HomeState>()
          .having((s) => s.estado, 'estado', EstadoInicio.listo)
          .having((s) => s.nombre, 'nombre', 'Santiago')
          .having((s) => s.resumen!.prioridadesHoy.map((a) => a.id).toList(), 'hoy', ['h'])
          .having((s) => s.resumen!.proximoExamen?.id, 'examen', 'e')
          .having((s) => s.resumen!.hayNovedades, 'novedades', isTrue),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'si algo falla en la primera carga queda en error',
    setUp: () => when(() => inicio.notificaciones()).thenThrow(const AppException('Sin conexión.')),
    build: crear,
    act: (cubit) => cubit.cargar(),
    expect: () => [
      isA<HomeState>().having((s) => s.estado, 'estado', EstadoInicio.cargando),
      isA<HomeState>()
          .having((s) => s.estado, 'estado', EstadoInicio.error)
          .having((s) => s.mensaje, 'mensaje', 'Sin conexión.'),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'si falla al recargar, lo de antes se queda y solo avisa',
    build: crear,
    act: (cubit) async {
      await cubit.cargar();
      when(() => inicio.perfil()).thenThrow(const AppException('Sin conexión.'));
      await cubit.cargar();
    },
    skip: 2,
    expect: () => [
      isA<HomeState>()
          .having((s) => s.estado, 'estado', EstadoInicio.listo)
          .having((s) => s.aviso, 'aviso', 'Sin conexión.'),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'el círculo completa la tarea, o presenta el examen, y recarga',
    build: crear,
    act: (cubit) async {
      await cubit.marcar(deHoy);
      await cubit.marcar(examen);
    },
    verify: (_) {
      verify(() => tareas.completar('h')).called(1);
      verify(() => tareas.marcarPresentado('e')).called(1);
      verify(() => inicio.perfil()).called(2);
    },
  );
}
