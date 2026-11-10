import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';
import 'package:studyflow/features/study_blocks/ui/bloc/new_study_block_cubit.dart';
import 'package:studyflow/features/study_blocks/ui/bloc/study_block_cubit.dart';

import '../calendar/fixtures.dart';

class _MockBloques extends Mock implements StudyBlocksRepository {}

class _MockCalendario extends Mock implements CalendarRepository {}

void main() {
  DateTime a(int hora) => DateTime(2026, 11, 9, hora);
  final repaso = bloque('b1', inicio: a(13), fin: a(15));
  final taller = actividad('a1', fecha: DateTime(2026, 11, 10, 23, 59));
  final calculoLunes = clase(
    'Cálculo Integral',
    1,
    const Hora(9, 0),
    const Hora(11, 0),
  );

  late _MockBloques bloques;
  late _MockCalendario calendario;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(repaso);
  });

  setUp(() {
    bloques = _MockBloques();
    calendario = _MockCalendario();
    when(() => bloques.actividad('a1')).thenAnswer((_) async => taller);
    when(() => bloques.actividadesAbiertas()).thenAnswer((_) async => [taller]);
    when(() => bloques.completarBloque(any())).thenAnswer((_) async {});
    when(() => bloques.descartarBloque(any())).thenAnswer((_) async {});
    when(
      () => bloques.reprogramarBloque(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => bloques.estadoDeActividad(any()),
    ).thenAnswer((_) async => EstadoActividad.enProgreso);
    when(
      () => bloques.crearBloque(any()),
    ).thenAnswer((i) async => i.positionalArguments.first as BloqueEstudio);
    when(() => calendario.horarios()).thenAnswer((_) async => [calculoLunes]);
    when(
      () => calendario.bloquesEntre(any(), any()),
    ).thenAnswer((_) async => [repaso]);
  });

  group('StudyBlockCubit', () {
    blocTest<StudyBlockCubit, StudyBlockState>(
      'carga la tarea vinculada',
      build: () => StudyBlockCubit(bloques, repaso),
      act: (cubit) => cubit.cargar(),
      expect: () => [StudyBlockState(bloque: repaso, actividad: taller)],
    );

    blocTest<StudyBlockCubit, StudyBlockState>(
      'completar deja el bloque completado y avisa',
      build: () => StudyBlockCubit(bloques, repaso),
      act: (cubit) => cubit.completar(),
      skip: 1,
      expect: () => [
        isA<StudyBlockState>()
            .having((s) => s.resultado, 'resultado', ResultadoBloque.completado)
            .having((s) => s.bloque.estado, 'estado', EstadoBloque.completado),
      ],
      verify: (_) => verify(() => bloques.completarBloque('b1')).called(1),
    );

    blocTest<StudyBlockCubit, StudyBlockState>(
      'descartar deja el bloque descartado',
      build: () => StudyBlockCubit(bloques, repaso),
      act: (cubit) => cubit.descartar(),
      skip: 1,
      expect: () => [
        isA<StudyBlockState>().having(
          (s) => s.resultado,
          'resultado',
          ResultadoBloque.descartado,
        ),
      ],
      verify: (_) => verify(() => bloques.descartarBloque('b1')).called(1),
    );

    blocTest<StudyBlockCubit, StudyBlockState>(
      'si falla avisa y el bloque sigue pendiente',
      setUp: () => when(
        () => bloques.descartarBloque(any()),
      ).thenThrow(const AppException('Sin conexión.')),
      build: () => StudyBlockCubit(bloques, repaso),
      act: (cubit) => cubit.descartar(),
      skip: 1,
      expect: () => [StudyBlockState(bloque: repaso, error: 'Sin conexión.')],
    );
  });

  group('NewStudyBlockCubit', () {
    blocTest<NewStudyBlockCubit, NewStudyBlockState>(
      'carga las actividades abiertas',
      build: () => NewStudyBlockCubit(bloques, calendario),
      act: (cubit) => cubit.cargar(),
      expect: () => [
        const NewStudyBlockState(),
        NewStudyBlockState(
          status: NewStudyBlockStatus.listo,
          actividades: [taller],
        ),
      ],
    );

    blocTest<NewStudyBlockCubit, NewStudyBlockState>(
      'guarda un bloque en un horario libre',
      build: () => NewStudyBlockCubit(bloques, calendario),
      act: (cubit) => cubit.guardar(
        inicio: a(16),
        minutos: 90,
        actividadId: 'a1',
        avisoMin: 15,
      ),
      expect: () => [
        const NewStudyBlockState(guardando: true),
        const NewStudyBlockState(guardado: true),
      ],
      verify: (_) {
        final creado =
            verify(() => bloques.crearBloque(captureAny())).captured.single
                as BloqueEstudio;
        expect(creado.inicio, a(16));
        expect(creado.fin, DateTime(2026, 11, 9, 17, 30));
        expect(creado.avisoMin, 15);
      },
    );

    blocTest<NewStudyBlockCubit, NewStudyBlockState>(
      'no guarda si se cruza con una clase y dice con cuál',
      build: () => NewStudyBlockCubit(bloques, calendario),
      act: (cubit) =>
          cubit.guardar(inicio: a(10), minutos: 60, actividadId: 'a1'),
      expect: () => [
        const NewStudyBlockState(guardando: true),
        const NewStudyBlockState(
          errorGuardar:
              'Se cruza con tu clase de Cálculo Integral (9:00 a. m. – 11:00 a. m.).',
        ),
      ],
      verify: (_) => verifyNever(() => bloques.crearBloque(any())),
    );

    blocTest<NewStudyBlockCubit, NewStudyBlockState>(
      'reprogramar mueve el mismo bloque',
      build: () => NewStudyBlockCubit(bloques, calendario),
      act: (cubit) =>
          cubit.guardar(inicio: a(14), minutos: 120, reprogramar: repaso),
      expect: () => [
        const NewStudyBlockState(guardando: true),
        const NewStudyBlockState(guardado: true),
      ],
      verify: (_) {
        verify(() => bloques.reprogramarBloque('b1', a(14), a(16))).called(1);
        verifyNever(() => bloques.crearBloque(any()));
      },
    );
  });
}
