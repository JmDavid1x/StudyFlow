import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/features/calendar/calendar_di.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_bloc.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_event.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_state.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/completar_bloque.dart';
import 'package:studyflow/features/study_blocks/study_blocks_di.dart';
import 'package:studyflow/features/study_blocks/ui/bloc/new_study_block_cubit.dart';
import 'package:studyflow/features/study_blocks/ui/bloc/study_block_cubit.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';
import 'package:studyflow/features/task_form/task_form_di.dart';
import 'package:studyflow/features/task_form/ui/bloc/task_form_cubit.dart';
import 'package:studyflow/features/task_form/ui/bloc/task_form_state.dart';

import 'fixtures.dart';

class _FalsoCalendario extends Mock implements CalendarRepository {}

class _FalsoBloques extends Mock implements StudyBlocksRepository {}

class _FalsoFormulario extends Mock implements TaskFormRepository {}

/// GetIt de formulario, calendario y bloques: se registran las partes reales y
/// se cambian los repositorios por falsos. Así se prueba que los Blocs y
/// Cubits que entrega `sl` usan lo registrado (y no crean Supabase por su cuenta).
void main() {
  late _FalsoCalendario calendario;
  late _FalsoBloques bloques;
  late _FalsoFormulario formulario;
  final repaso = bloque(
    'b1',
    inicio: DateTime(2026, 11, 9, 13),
    fin: DateTime(2026, 11, 9, 15),
  );

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() async {
    await sl.reset();
    registrarTaskForm(sl);
    registrarCalendar(sl);
    registrarStudyBlocks(sl);

    calendario = _FalsoCalendario();
    bloques = _FalsoBloques();
    formulario = _FalsoFormulario();
    await sl.unregister<CalendarRepository>();
    await sl.unregister<StudyBlocksRepository>();
    await sl.unregister<TaskFormRepository>();
    sl.registerSingleton<CalendarRepository>(calendario);
    sl.registerSingleton<StudyBlocksRepository>(bloques);
    sl.registerSingleton<TaskFormRepository>(formulario);

    when(() => calendario.horarios()).thenAnswer((_) async => []);
    when(
      () => calendario.actividadesEntre(any(), any()),
    ).thenAnswer((_) async => []);
    when(
      () => calendario.bloquesEntre(any(), any()),
    ).thenAnswer((_) async => [repaso]);
    when(() => formulario.materiasConComponentes()).thenAnswer((_) async => []);
    when(() => formulario.porcentajesAsignados()).thenAnswer((_) async => []);
    when(() => bloques.actividadesAbiertas()).thenAnswer((_) async => []);
    when(
      () => bloques.actividad(any()),
    ).thenAnswer((_) async => actividad('a1', fecha: DateTime(2026, 11, 10)));
  });

  tearDown(() => sl.reset());

  test(
    'CalendarBloc sale de GetIt y carga con el repositorio registrado',
    () async {
      final bloc = sl<CalendarBloc>()..add(const CalendarioIniciado());
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<CalendarState>().having(
            (s) => s.status,
            'status',
            CalendarStatus.listo,
          ),
        ),
      );
      verify(() => calendario.bloquesEntre(any(), any())).called(1);
      await bloc.close();
    },
  );

  test(
    'TaskFormCubit sale de GetIt y trae las materias del repositorio',
    () async {
      final cubit = sl<TaskFormCubit>();
      await cubit.cargar();
      expect(cubit.state.status, TaskFormStatus.listo);
      verify(() => formulario.materiasConComponentes()).called(1);
      await cubit.close();
    },
  );

  test(
    'StudyBlockCubit recibe el bloque de la ruta (registerFactoryParam)',
    () async {
      final cubit = sl<StudyBlockCubit>(param1: repaso);
      expect(cubit.state.bloque, repaso);
      await cubit.cargar();
      verify(() => bloques.actividad('a1')).called(1);
      await cubit.close();
    },
  );

  test('NewStudyBlockCubit sale de GetIt con sus casos de uso', () async {
    final cubit = sl<NewStudyBlockCubit>();
    await cubit.cargar();
    expect(cubit.state.status, NewStudyBlockStatus.listo);
    verify(() => bloques.actividadesAbiertas()).called(1);
    await cubit.close();
  });

  test(
    'los Blocs y casos de uso son nuevos cada vez; los repositorios son uno solo',
    () async {
      final a = sl<CalendarBloc>();
      final b = sl<CalendarBloc>();
      expect(a, isNot(same(b)));
      expect(sl<CompletarBloque>(), isNot(same(sl<CompletarBloque>())));
      expect(sl<CalendarRepository>(), same(calendario));
      expect(sl<StudyBlocksRepository>(), same(bloques));
      await a.close();
      await b.close();
    },
  );
}
