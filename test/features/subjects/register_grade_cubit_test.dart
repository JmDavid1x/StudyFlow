import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';
import 'package:studyflow/features/subjects/ui/bloc/register_grade_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/register_grade_state.dart';

import 'fixtures_materias.dart';

class _MockRepo extends Mock implements SubjectsRepository {}

void main() {
  late _MockRepo repo;

  final materia = materiaDePrueba(
    componentes: [
      componenteDePrueba('c1', nombre: 'Talleres', porcentaje: 50),
      componenteDePrueba('c2', nombre: 'Parciales', porcentaje: 50),
    ],
  );
  final taller1 = actividadDePrueba(
    'a1',
    componenteId: 'c1',
    porcentaje: 25,
    nota: 4.0,
  );
  final taller2 = actividadDePrueba('a2', componenteId: 'c1', porcentaje: 25);
  final parcial = actividadDePrueba('a3', componenteId: 'c2', porcentaje: 50);

  setUp(() {
    repo = _MockRepo();
    when(
      () => repo.actividadesConNota('m1'),
    ).thenAnswer((_) async => [taller1, taller2, parcial]);
  });

  RegisterGradeCubit crear({Materia? m, Actividad? actividad}) =>
      RegisterGradeCubit(repo, materia: m, actividad: actividad);

  group('cargar', () {
    blocTest<RegisterGradeCubit, RegisterGradeState>(
      'preselecciona la primera actividad sin nota',
      build: () => crear(m: materia),
      act: (c) => c.cargar(),
      expect: () => [
        const RegisterGradeLoading(),
        isA<RegisterGradeReady>()
            .having((s) => s.actividadId, 'actividad', 'a2')
            .having((s) => s.componenteId, 'componente', 'c1')
            .having((s) => s.decimas, 'décimas', 30),
      ],
    );

    blocTest<RegisterGradeCubit, RegisterGradeState>(
      'si llega una actividad (desde el examen) la deja preseleccionada',
      setUp: () => when(
        () => repo.materiasDelPeriodo(),
      ).thenAnswer((_) async => [materia]),
      build: () => crear(actividad: parcial.actividad),
      act: (c) => c.cargar(),
      expect: () => [
        const RegisterGradeLoading(),
        isA<RegisterGradeReady>()
            .having((s) => s.actividadId, 'actividad', 'a3')
            .having((s) => s.componenteId, 'componente', 'c2'),
      ],
    );

    blocTest<RegisterGradeCubit, RegisterGradeState>(
      'sin argumento usa la primera materia del periodo',
      setUp: () => when(
        () => repo.materiasDelPeriodo(),
      ).thenAnswer((_) async => [materia]),
      build: crear,
      act: (c) => c.cargar(),
      expect: () => [const RegisterGradeLoading(), isA<RegisterGradeReady>()],
    );

    blocTest<RegisterGradeCubit, RegisterGradeState>(
      'sin materias emite vacío',
      setUp: () =>
          when(() => repo.materiasDelPeriodo()).thenAnswer((_) async => []),
      build: crear,
      act: (c) => c.cargar(),
      expect: () => [const RegisterGradeLoading(), isA<RegisterGradeEmpty>()],
    );

    blocTest<RegisterGradeCubit, RegisterGradeState>(
      'materia sin actividades emite vacío',
      setUp: () =>
          when(() => repo.actividadesConNota('m1')).thenAnswer((_) async => []),
      build: () => crear(m: materia),
      act: (c) => c.cargar(),
      expect: () => [const RegisterGradeLoading(), isA<RegisterGradeEmpty>()],
    );

    blocTest<RegisterGradeCubit, RegisterGradeState>(
      'si falla emite error',
      setUp: () => when(
        () => repo.actividadesConNota('m1'),
      ).thenThrow(const AppException('Sin conexión')),
      build: () => crear(m: materia),
      act: (c) => c.cargar(),
      expect: () => [
        const RegisterGradeLoading(),
        const RegisterGradeError('Sin conexión'),
      ],
    );
  });

  group('elegir', () {
    blocTest<RegisterGradeCubit, RegisterGradeState>(
      'cambiar de componente elige su primera actividad sin nota',
      build: () => crear(m: materia),
      act: (c) async {
        await c.cargar();
        c.elegirComponente('c2');
      },
      skip: 2,
      expect: () => [
        isA<RegisterGradeReady>()
            .having((s) => s.actividadId, 'actividad', 'a3')
            .having((s) => s.componenteId, 'componente', 'c2'),
      ],
    );

    blocTest<RegisterGradeCubit, RegisterGradeState>(
      'elegir una actividad ya calificada trae su nota',
      build: () => crear(m: materia),
      act: (c) async {
        await c.cargar();
        c.elegirActividad('a1');
      },
      skip: 2,
      expect: () => [
        isA<RegisterGradeReady>().having((s) => s.decimas, 'décimas', 40),
      ],
    );

    blocTest<RegisterGradeCubit, RegisterGradeState>(
      'la nota se limita entre 0.0 y 5.0',
      build: () => crear(m: materia),
      act: (c) async {
        await c.cargar();
        c.cambiarDecimas(99);
        c.cambiarDecimas(-4);
      },
      skip: 2,
      expect: () => [
        isA<RegisterGradeReady>().having((s) => s.decimas, 'máximo', 50),
        isA<RegisterGradeReady>().having((s) => s.decimas, 'mínimo', 0),
      ],
    );
  });

  group('guardar', () {
    blocTest<RegisterGradeCubit, RegisterGradeState>(
      'guarda la nota, recarga y reporta antes y después',
      setUp: () {
        when(() => repo.registrarNota(any(), any())).thenAnswer((_) async {});
        var guardada = false;
        when(() => repo.actividadesConNota('m1')).thenAnswer((_) async {
          final a2 = guardada
              ? actividadDePrueba(
                  'a2',
                  componenteId: 'c1',
                  porcentaje: 25,
                  nota: 3.0,
                )
              : taller2;
          return [taller1, a2, parcial];
        });
        when(() => repo.registrarNota('a2', 3.0)).thenAnswer((_) async {
          guardada = true;
        });
      },
      build: () => crear(m: materia),
      act: (c) async {
        await c.cargar();
        await c.guardar();
      },
      skip: 2,
      expect: () => [
        isA<RegisterGradeReady>().having((s) => s.guardando, 'guardando', true),
        isA<RegisterGradeReady>()
            .having((s) => s.guardando, 'guardando', false)
            .having((s) => s.guardada?.antes, 'antes', closeTo(4.0, 1e-9))
            .having((s) => s.guardada?.despues, 'después', closeTo(3.5, 1e-9))
            .having(
              (s) => s.actividades.where((a) => a.tieneNota).length,
              'calificadas',
              2,
            ),
      ],
      verify: (_) => verify(() => repo.registrarNota('a2', 3.0)).called(1),
    );

    blocTest<RegisterGradeCubit, RegisterGradeState>(
      'si falla muestra el error y no pierde lo elegido',
      setUp: () => when(
        () => repo.registrarNota(any(), any()),
      ).thenThrow(const AppException('Sin conexión')),
      build: () => crear(m: materia),
      act: (c) async {
        await c.cargar();
        await c.guardar();
      },
      skip: 2,
      expect: () => [
        isA<RegisterGradeReady>().having((s) => s.guardando, 'guardando', true),
        isA<RegisterGradeReady>()
            .having((s) => s.errorAlGuardar, 'error', 'Sin conexión')
            .having((s) => s.guardando, 'guardando', false)
            .having((s) => s.guardada, 'guardada', isNull),
      ],
    );
  });
}
