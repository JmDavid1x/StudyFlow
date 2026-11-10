import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';
import 'package:studyflow/features/subjects/domain/usecases/obtener_resumen_semestre.dart';
import 'package:studyflow/features/subjects/ui/bloc/subject_detail_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/subject_detail_state.dart';
import 'package:studyflow/features/subjects/ui/bloc/subjects_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/subjects_state.dart';

import 'fixtures_materias.dart';

class _MockRepo extends Mock implements SubjectsRepository {}

void main() {
  late _MockRepo repo;

  setUp(() => repo = _MockRepo());

  group('SubjectsCubit', () {
    blocTest<SubjectsCubit, SubjectsState>(
      'sin materias emite cargando y vacío',
      setUp: () =>
          when(() => repo.materiasDelPeriodo()).thenAnswer((_) async => []),
      build: () => SubjectsCubit(ObtenerResumenSemestre(repo)),
      act: (c) => c.cargar(),
      expect: () => [const SubjectsLoading(), const SubjectsEmpty()],
    );

    blocTest<SubjectsCubit, SubjectsState>(
      'con materias emite cargando y listo',
      setUp: () {
        when(
          () => repo.materiasDelPeriodo(),
        ).thenAnswer((_) async => [materiaDePrueba()]);
        when(() => repo.actividadesConNota('m1')).thenAnswer(
          (_) async => [actividadDePrueba('1', porcentaje: 50, nota: 4.0)],
        );
      },
      build: () => SubjectsCubit(ObtenerResumenSemestre(repo)),
      act: (c) => c.cargar(),
      expect: () => [
        const SubjectsLoading(),
        isA<SubjectsLoaded>().having(
          (s) => s.resumen.promedio,
          'promedio',
          closeTo(4.0, 1e-9),
        ),
      ],
    );

    blocTest<SubjectsCubit, SubjectsState>(
      'si falla emite error con el mensaje',
      setUp: () => when(
        () => repo.materiasDelPeriodo(),
      ).thenThrow(const AppException('Sin conexión')),
      build: () => SubjectsCubit(ObtenerResumenSemestre(repo)),
      act: (c) => c.cargar(),
      expect: () => [
        const SubjectsLoading(),
        const SubjectsError('Sin conexión'),
      ],
    );
  });

  group('SubjectDetailCubit', () {
    blocTest<SubjectDetailCubit, SubjectDetailState>(
      'carga actividades y calcula el resumen de la materia recibida',
      setUp: () => when(() => repo.actividadesConNota('m1')).thenAnswer(
        (_) async => [
          actividadDePrueba('1', porcentaje: 30, nota: 4.0),
          actividadDePrueba('2', porcentaje: 20, nota: 3.0),
        ],
      ),
      build: () => SubjectDetailCubit(
        repo,
        materia: materiaDePrueba(componentes: [componenteDePrueba('c1')]),
      ),
      act: (c) => c.cargar(),
      expect: () => [
        const SubjectDetailLoading(),
        isA<SubjectDetailLoaded>()
            .having((s) => s.resumen.notaAcumulada, 'nota', closeTo(3.6, 1e-9))
            .having((s) => s.resumen.porcentajeEvaluado, 'evaluado', 50)
            .having((s) => s.resumen.notaQueFalta, 'falta', closeTo(4.4, 1e-9))
            .having((s) => s.componentes.length, 'componentes', 1),
      ],
    );

    blocTest<SubjectDetailCubit, SubjectDetailState>(
      'sin materia en el argumento usa la primera del periodo',
      setUp: () {
        when(
          () => repo.materiasDelPeriodo(),
        ).thenAnswer((_) async => [materiaDePrueba(nombre: 'Primera')]);
        when(() => repo.actividadesConNota('m1')).thenAnswer((_) async => []);
      },
      build: () => SubjectDetailCubit(repo),
      act: (c) => c.cargar(),
      expect: () => [
        const SubjectDetailLoading(),
        isA<SubjectDetailLoaded>().having(
          (s) => s.materia.nombre,
          'materia',
          'Primera',
        ),
      ],
    );

    blocTest<SubjectDetailCubit, SubjectDetailState>(
      'sin argumento y sin materias emite vacío (no se rompe)',
      setUp: () =>
          when(() => repo.materiasDelPeriodo()).thenAnswer((_) async => []),
      build: () => SubjectDetailCubit(repo),
      act: (c) => c.cargar(),
      expect: () => [const SubjectDetailLoading(), const SubjectDetailEmpty()],
    );

    blocTest<SubjectDetailCubit, SubjectDetailState>(
      'si falla emite error',
      setUp: () => when(
        () => repo.actividadesConNota(any()),
      ).thenThrow(const AppException('Sin conexión')),
      build: () => SubjectDetailCubit(repo, materia: materiaDePrueba()),
      act: (c) => c.cargar(),
      expect: () => [
        const SubjectDetailLoading(),
        const SubjectDetailError('Sin conexión'),
      ],
    );
  });
}
