import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/home/domain/home_repository.dart';
import 'package:studyflow/features/home/domain/resumen_inicio.dart';
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

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(EstadoActividad.porHacer);
  });

  setUp(() {
    inicio = _MockHomeRepository();
    tareas = _MockTasksRepository();
    when(() => inicio.perfil()).thenAnswer((_) async => perfil);
    when(() => inicio.actividadesEntre(any(), any())).thenAnswer((_) async => [deHoy, manana, examen]);
    when(() => inicio.proximoExamen(any())).thenAnswer((_) async => examen);
    when(() => inicio.bloquesEntre(any(), any())).thenAnswer((_) async => []);
    when(
      () => inicio.notificaciones(),
    ).thenAnswer((_) async => [notificacion('n1', programadaPara: DateTime(2026, 11, 11, 7))]);
    when(() => tareas.marcarCompletada(any())).thenAnswer((_) async {});
    when(() => tareas.cancelarBloquesPendientes(any())).thenAnswer((_) async {});
    when(() => tareas.marcarPresentado(any())).thenAnswer((_) async {});
    when(() => tareas.restaurarEstado(any(), any())).thenAnswer((_) async {});
    when(() => tareas.hayMaterias()).thenAnswer((_) async => true);
    when(() => tareas.hayMaterias()).thenAnswer((_) async => true);
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
    'el próximo examen sale aunque sea a más de 8 días (fuera del rango de Inicio)',
    setUp: () {
      final lejano = actividad('lejos', fecha: DateTime(2026, 12, 2, 8), tipo: TipoActividad.examen);
      when(() => inicio.actividadesEntre(any(), any())).thenAnswer((_) async => [deHoy, manana]);
      when(() => inicio.proximoExamen(any())).thenAnswer((_) async => lejano);
    },
    build: crear,
    act: (cubit) => cubit.cargar(),
    skip: 1,
    expect: () => [isA<HomeState>().having((s) => s.resumen!.proximoExamen?.id, 'examen', 'lejos')],
    verify: (_) => verify(() => inicio.proximoExamen(ahora)).called(1),
  );

  blocTest<HomeCubit, HomeState>(
    'si completar falla avisa con el mensaje y recarga',
    setUp: () => when(() => tareas.cancelarBloquesPendientes(any())).thenThrow(const AppException('Sin conexión.')),
    build: crear,
    act: (cubit) => cubit.marcar(deHoy),
    verify: (cubit) {
      expect(cubit.state.aviso, 'Sin conexión.');
      verify(() => tareas.restaurarEstado('h', EstadoActividad.porHacer)).called(1);
      verify(() => inicio.perfil()).called(1);
    },
  );

  blocTest<HomeCubit, HomeState>(
    'sin nada que entregar ni materias: el estado vacío pide la primera materia',
    setUp: () {
      when(() => inicio.actividadesEntre(any(), any())).thenAnswer((_) async => []);
      when(() => inicio.proximoExamen(any())).thenAnswer((_) async => null);
      when(() => tareas.hayMaterias()).thenAnswer((_) async => false);
    },
    build: crear,
    act: (cubit) => cubit.cargar(),
    skip: 1,
    expect: () => [isA<HomeState>().having((s) => s.vacio, 'vacío', VacioInicio.sinMaterias)],
  );

  blocTest<HomeCubit, HomeState>(
    'con pendientes no hay estado vacío ni se pregunta por las materias',
    build: crear,
    act: (cubit) => cubit.cargar(),
    skip: 1,
    expect: () => [isA<HomeState>().having((s) => s.vacio, 'vacío', isNull)],
    verify: (_) => verifyNever(() => tareas.hayMaterias()),
  );

  blocTest<HomeCubit, HomeState>(
    'dos cargas pedidas a la vez no se pisan: la segunda corre al terminar la primera',
    build: crear,
    act: (cubit) => Future.wait([cubit.cargar(), cubit.cargar(), cubit.cargar()]),
    verify: (_) => verify(() => inicio.perfil()).called(2),
  );

  blocTest<HomeCubit, HomeState>(
    'varios cambios en vivo seguidos hacen una sola recarga',
    build: crear,
    act: (cubit) {
      cubit.cambioEnVivo();
      cubit.cambioEnVivo();
      cubit.cambioEnVivo();
    },
    wait: const Duration(milliseconds: 600),
    verify: (_) => verify(() => inicio.perfil()).called(1),
  );

  group('estados vacíos', () {
    void sinNada() {
      when(() => inicio.actividadesEntre(any(), any())).thenAnswer((_) async => []);
      when(() => inicio.proximoExamen(any())).thenAnswer((_) async => null);
    }

    blocTest<HomeCubit, HomeState>(
      'sin materias pide crear la primera',
      setUp: () {
        sinNada();
        when(() => tareas.hayMaterias()).thenAnswer((_) async => false);
      },
      build: crear,
      act: (cubit) => cubit.cargar(),
      verify: (cubit) => expect(cubit.state.vacio, VacioInicio.sinMaterias),
    );

    blocTest<HomeCubit, HomeState>(
      'con materias y sin entregas pide crear la primera entrega',
      setUp: sinNada,
      build: crear,
      act: (cubit) => cubit.cargar(),
      verify: (cubit) => expect(cubit.state.vacio, VacioInicio.sinEntregas),
    );

    blocTest<HomeCubit, HomeState>(
      'todo lo de la semana cerrado: al día',
      setUp: () {
        when(() => inicio.actividadesEntre(any(), any())).thenAnswer(
          (_) async => [actividad('c', fecha: DateTime(2026, 11, 10, 8), estado: EstadoActividad.completada)],
        );
        when(() => inicio.proximoExamen(any())).thenAnswer((_) async => null);
      },
      build: crear,
      act: (cubit) => cubit.cargar(),
      verify: (cubit) {
        expect(cubit.state.vacio, VacioInicio.todoAlDia);
        verifyNever(() => tareas.hayMaterias());
      },
    );

    blocTest<HomeCubit, HomeState>(
      'con pendientes no hay estado vacío',
      build: crear,
      act: (cubit) => cubit.cargar(),
      verify: (cubit) => expect(cubit.state.vacio, isNull),
    );
  });

  blocTest<HomeCubit, HomeState>(
    'varios cambios en vivo seguidos hacen una sola recarga',
    build: crear,
    act: (cubit) {
      cubit
        ..cambioEnVivo()
        ..cambioEnVivo()
        ..cambioEnVivo();
    },
    wait: const Duration(milliseconds: 600),
    verify: (_) => verify(() => inicio.perfil()).called(1),
  );

  blocTest<HomeCubit, HomeState>(
    'si piden cargar mientras ya carga, no se pisan: una más al terminar',
    build: crear,
    act: (cubit) => Future.wait([cubit.cargar(), cubit.cargar(), cubit.cargar()]),
    verify: (_) => verify(() => inicio.perfil()).called(2),
  );

  blocTest<HomeCubit, HomeState>(
    'recargar con datos no vuelve a "Cargando" (no parpadea)',
    build: crear,
    act: (cubit) async {
      await cubit.cargar();
      await cubit.cargar();
    },
    skip: 2,
    verify: (cubit) => expect(cubit.state.estado, EstadoInicio.listo),
    expect: () => isNot(contains(isA<HomeState>().having((s) => s.estado, 'estado', EstadoInicio.cargando))),
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
      verify(() => tareas.marcarCompletada('h')).called(1);
      verify(() => tareas.marcarPresentado('e')).called(1);
      verify(() => inicio.perfil()).called(2);
    },
  );
}
