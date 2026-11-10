import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';
import 'package:studyflow/features/subjects/domain/usecases/guardar_materia.dart';
import 'package:studyflow/features/subjects/domain/usecases/terminar_configuracion.dart';
import 'package:studyflow/features/subjects/ui/bloc/new_subject_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/setup_reminders_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/setup_subjects_cubit.dart';

import 'fixtures_materias.dart';

class _MockRepo extends Mock implements SubjectsRepository {}

void main() {
  late _MockRepo repo;

  setUp(() => repo = _MockRepo());

  group('SetupSubjectsCubit', () {
    blocTest<SetupSubjectsCubit, SetupSubjectsState>(
      'carga las materias del periodo',
      setUp: () => when(
        () => repo.materiasDelPeriodo(),
      ).thenAnswer((_) async => [materiaDePrueba()]),
      build: () => SetupSubjectsCubit(repo),
      act: (c) => c.cargar(),
      expect: () => [
        const SetupSubjectsLoading(),
        SetupSubjectsLoaded([materiaDePrueba()]),
      ],
    );

    blocTest<SetupSubjectsCubit, SetupSubjectsState>(
      'sin materias queda cargado con lista vacía',
      setUp: () =>
          when(() => repo.materiasDelPeriodo()).thenAnswer((_) async => []),
      build: () => SetupSubjectsCubit(repo),
      act: (c) => c.cargar(),
      expect: () => [
        const SetupSubjectsLoading(),
        const SetupSubjectsLoaded([]),
      ],
    );

    blocTest<SetupSubjectsCubit, SetupSubjectsState>(
      'si falla emite error',
      setUp: () => when(
        () => repo.materiasDelPeriodo(),
      ).thenThrow(const AppException('Sin conexión')),
      build: () => SetupSubjectsCubit(repo),
      act: (c) => c.cargar(),
      expect: () => [
        const SetupSubjectsLoading(),
        const SetupSubjectsError('Sin conexión'),
      ],
    );
  });

  group('NewSubjectCubit', () {
    blocTest<NewSubjectCubit, NewSubjectState>(
      'si los componentes no suman 100 muestra el error y no guarda',
      setUp: () =>
          when(() => repo.periodoActivo()).thenAnswer((_) async => null),
      build: () => NewSubjectCubit(GuardarMateria(repo)),
      act: (c) => c.guardar(
        nombre: 'Cálculo',
        creditos: 3,
        colorHex: '#A78BFA',
        metaNota: 4.0,
        horarios: const [],
        componentes: [componenteDePrueba('', porcentaje: 60)],
      ),
      expect: () => [
        const NewSubjectState(guardando: true),
        const NewSubjectState(
          error: 'Los componentes de la nota deben sumar 100 %.',
        ),
      ],
      verify: (_) => verifyNever(() => repo.periodoActivo()),
    );
  });

  group('SetupRemindersCubit', () {
    blocTest<SetupRemindersCubit, SetupRemindersState>(
      'guarda la configuración y termina',
      setUp: () => when(
        () =>
            repo.terminarConfiguracion(pushActivas: any(named: 'pushActivas')),
      ).thenAnswer((_) async {}),
      build: () => SetupRemindersCubit(TerminarConfiguracion(repo)),
      act: (c) => c.terminar(pushActivas: true),
      expect: () => [
        const SetupRemindersState(guardando: true),
        const SetupRemindersState(terminado: true),
      ],
      verify: (_) =>
          verify(() => repo.terminarConfiguracion(pushActivas: true)).called(1),
    );

    blocTest<SetupRemindersCubit, SetupRemindersState>(
      '"Ahora no" también termina, con recordatorios apagados',
      setUp: () => when(
        () =>
            repo.terminarConfiguracion(pushActivas: any(named: 'pushActivas')),
      ).thenAnswer((_) async {}),
      build: () => SetupRemindersCubit(TerminarConfiguracion(repo)),
      act: (c) => c.terminar(pushActivas: false),
      expect: () => [
        const SetupRemindersState(guardando: true),
        const SetupRemindersState(terminado: true),
      ],
      verify: (_) => verify(
        () => repo.terminarConfiguracion(pushActivas: false),
      ).called(1),
    );

    blocTest<SetupRemindersCubit, SetupRemindersState>(
      'si falla muestra el error y no termina',
      setUp: () => when(
        () =>
            repo.terminarConfiguracion(pushActivas: any(named: 'pushActivas')),
      ).thenThrow(const AppException('Sin conexión')),
      build: () => SetupRemindersCubit(TerminarConfiguracion(repo)),
      act: (c) => c.terminar(pushActivas: true),
      expect: () => [
        const SetupRemindersState(guardando: true),
        const SetupRemindersState(error: 'Sin conexión'),
      ],
    );
  });
}
