import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/calendar/domain/agenda_del_dia.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_bloc.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_event.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_state.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';

import 'fixtures.dart';

class _MockCalendario extends Mock implements CalendarRepository {}

class _MockBloques extends Mock implements StudyBlocksRepository {}

void main() {
  // "Hoy" en las pruebas: miércoles 11 de noviembre de 2026, 10:00 a. m.
  DateTime ahora() => DateTime(2026, 11, 11, 10);
  final semana = DateTime(2026, 11, 9);
  final siguiente = DateTime(2026, 11, 16);
  final miercoles = DateTime(2026, 11, 11);

  final calculoLunes = clase(
    'Cálculo Integral',
    1,
    const Hora(9, 0),
    const Hora(11, 0),
  );
  final taller = actividad('taller', fecha: DateTime(2026, 11, 11, 23, 59));
  final repaso = bloque(
    'b1',
    inicio: DateTime(2026, 11, 11, 13),
    fin: DateTime(2026, 11, 11, 15),
  );

  late _MockCalendario calendario;
  late _MockBloques bloques;

  CalendarBloc crear() => CalendarBloc(calendario, bloques, ahora: ahora);

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() {
    calendario = _MockCalendario();
    bloques = _MockBloques();
    when(() => calendario.horarios()).thenAnswer((_) async => [calculoLunes]);
    when(
      () => calendario.actividadesEntre(any(), any()),
    ).thenAnswer((_) async => [taller]);
    when(
      () => calendario.bloquesEntre(any(), any()),
    ).thenAnswer((_) async => [repaso]);
    when(() => bloques.completarBloque(any())).thenAnswer((_) async {});
    when(
      () => bloques.marcarActividadEnProgreso(any()),
    ).thenAnswer((_) async {});
    when(
      () => bloques.estadoDeActividad(any()),
    ).thenAnswer((_) async => EstadoActividad.porHacer);
  });

  test('arranca en el día de hoy, cargando', () {
    final bloc = crear();
    expect(bloc.state.dia, miercoles);
    expect(bloc.state.semana, semana);
    expect(bloc.state.status, CalendarStatus.cargando);
    bloc.close();
  });

  blocTest<CalendarBloc, CalendarState>(
    'al iniciar trae la semana de lunes a lunes y arma la agenda del día',
    build: crear,
    act: (bloc) => bloc.add(const CalendarioIniciado()),
    verify: (bloc) {
      verify(() => calendario.actividadesEntre(semana, siguiente)).called(1);
      verify(() => calendario.bloquesEntre(semana, siguiente)).called(1);
      expect(bloc.state.status, CalendarStatus.listo);
      expect(bloc.state.agenda.map((e) => e.runtimeType), [
        BloqueEnAgenda,
        EntregaEnAgenda,
      ]);
      expect(bloc.state.pendientes, 2);
      expect(bloc.state.tienePunto(miercoles), isTrue);
      expect(bloc.state.tienePunto(semana), isFalse);
    },
  );

  blocTest<CalendarBloc, CalendarState>(
    'elegir otro día de la misma semana no vuelve a pedir nada',
    build: crear,
    act: (bloc) async {
      bloc.add(const CalendarioIniciado());
      await Future<void>.delayed(Duration.zero);
      bloc.add(DiaElegido(DateTime(2026, 11, 9, 18)));
    },
    verify: (bloc) {
      verify(() => calendario.actividadesEntre(any(), any())).called(1);
      expect(bloc.state.dia, DateTime(2026, 11, 9));
      expect(bloc.state.agenda.single, isA<ClaseEnAgenda>());
    },
  );

  blocTest<CalendarBloc, CalendarState>(
    'las flechas piden la otra semana y los horarios solo una vez',
    build: crear,
    act: (bloc) async {
      bloc.add(const CalendarioIniciado());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const SemanaCambiada(1));
    },
    verify: (bloc) {
      verify(
        () => calendario.actividadesEntre(siguiente, DateTime(2026, 11, 23)),
      ).called(1);
      verify(() => calendario.horarios()).called(1);
      expect(bloc.state.semana, siguiente);
      expect(bloc.state.dia, DateTime(2026, 11, 18));
    },
  );

  blocTest<CalendarBloc, CalendarState>(
    'si falla muestra el error',
    setUp: () => when(
      () => calendario.actividadesEntre(any(), any()),
    ).thenThrow(const AppException('Sin conexión.')),
    build: crear,
    act: (bloc) => bloc.add(const CalendarioIniciado()),
    verify: (bloc) {
      expect(bloc.state.status, CalendarStatus.error);
      expect(bloc.state.error, 'Sin conexión.');
    },
  );

  blocTest<CalendarBloc, CalendarState>(
    'el circulito completa el bloque, avisa y recarga la semana',
    build: crear,
    seed: () => CalendarState(dia: miercoles, status: CalendarStatus.listo),
    act: (bloc) => bloc.add(BloqueCompletado(repaso)),
    expect: () => [
      isA<CalendarState>().having((s) => s.completado, 'completado', repaso),
      isA<CalendarState>()
          .having((s) => s.completado, 'completado', isNull)
          .having((s) => s.status, 'status', CalendarStatus.listo),
    ],
    verify: (_) {
      verify(() => bloques.completarBloque('b1')).called(1);
      verify(() => bloques.marcarActividadEnProgreso('a1')).called(1);
      verify(() => calendario.actividadesEntre(any(), any())).called(1);
    },
  );

  blocTest<CalendarBloc, CalendarState>(
    'no completa un bloque que ya no está pendiente',
    build: crear,
    seed: () => CalendarState(dia: miercoles, status: CalendarStatus.listo),
    act: (bloc) => bloc.add(
      BloqueCompletado(
        bloque(
          'b2',
          inicio: repaso.inicio,
          fin: repaso.fin,
          estado: EstadoBloque.completado,
        ),
      ),
    ),
    expect: () => [
      isA<CalendarState>().having(
        (s) => s.errorAccion,
        'error',
        'Este bloque ya no está pendiente.',
      ),
    ],
    verify: (_) => verifyNever(() => bloques.completarBloque(any())),
  );

  test('inicioDeSemana del estado coincide con la regla', () {
    expect(
      CalendarState(dia: DateTime(2026, 11, 15)).semana,
      inicioDeSemana(DateTime(2026, 11, 15)),
    );
  });
}
