import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/completar_bloque.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/crear_bloque.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/descartar_bloque.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/reprogramar_bloque.dart';

import '../calendar/fixtures.dart';

class _MockBloques extends Mock implements StudyBlocksRepository {}

class _MockCalendario extends Mock implements CalendarRepository {}

void main() {
  late _MockBloques bloques;
  late _MockCalendario calendario;
  DateTime a(int hora) => DateTime(2026, 11, 9, hora);
  final calculoLunes = clase(
    'Cálculo Integral',
    1,
    const Hora(9, 0),
    const Hora(11, 0),
  );

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(
      bloque('fallback', inicio: DateTime(2026), fin: DateTime(2026, 1, 2)),
    );
  });

  setUp(() {
    bloques = _MockBloques();
    calendario = _MockCalendario();
    when(() => calendario.horarios()).thenAnswer((_) async => [calculoLunes]);
    when(
      () => calendario.bloquesEntre(any(), any()),
    ).thenAnswer((_) async => []);
    when(() => bloques.completarBloque(any())).thenAnswer((_) async {});
    when(() => bloques.descartarBloque(any())).thenAnswer((_) async {});
    when(
      () => bloques.reprogramarBloque(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => bloques.marcarActividadEnProgreso(any()),
    ).thenAnswer((_) async {});
    when(() => bloques.crearBloque(any())).thenAnswer(
      (invocacion) async =>
          invocacion.positionalArguments.first as BloqueEstudio,
    );
  });

  group('CompletarBloque', () {
    test(
      'el primer bloque pasa la actividad de por hacer a en progreso',
      () async {
        when(
          () => bloques.estadoDeActividad('a1'),
        ).thenAnswer((_) async => EstadoActividad.porHacer);
        await CompletarBloque(bloques)(bloque('b1', inicio: a(13), fin: a(15)));
        verify(() => bloques.completarBloque('b1')).called(1);
        verify(() => bloques.marcarActividadEnProgreso('a1')).called(1);
      },
    );

    test('si la actividad ya estaba en progreso no la cambia', () async {
      when(
        () => bloques.estadoDeActividad('a1'),
      ).thenAnswer((_) async => EstadoActividad.enProgreso);
      await CompletarBloque(bloques)(bloque('b1', inicio: a(13), fin: a(15)));
      verify(() => bloques.completarBloque('b1')).called(1);
      verifyNever(() => bloques.marcarActividadEnProgreso(any()));
    });

    test('no completa un bloque que ya no está pendiente', () {
      final hecho = bloque(
        'b1',
        inicio: a(13),
        fin: a(15),
        estado: EstadoBloque.completado,
      );
      expect(
        () => CompletarBloque(bloques)(hecho),
        throwsA(isA<AppException>()),
      );
      verifyNever(() => bloques.completarBloque(any()));
    });
  });

  group('CrearBloque', () {
    test('crea un bloque pendiente si el horario está libre', () async {
      final creado = await CrearBloque(bloques, calendario)(
        actividadId: 'a1',
        inicio: a(13),
        fin: a(15),
        avisoMin: 15,
      );
      expect(creado.estado, EstadoBloque.pendiente);
      expect(creado.actividadId, 'a1');
      expect(creado.avisoMin, 15);
      verify(() => bloques.crearBloque(any())).called(1);
    });

    test('no lo crea si se cruza con una clase', () async {
      await expectLater(
        CrearBloque(bloques, calendario)(
          actividadId: 'a1',
          inicio: a(10),
          fin: a(12),
        ),
        throwsA(isA<AppException>()),
      );
      verifyNever(() => bloques.crearBloque(any()));
    });

    test('pide los bloques de los días que toca', () async {
      await CrearBloque(bloques, calendario)(
        actividadId: 'a1',
        inicio: a(13),
        fin: a(15),
      );
      verify(
        () => calendario.bloquesEntre(
          DateTime(2026, 11, 9),
          DateTime(2026, 11, 10),
        ),
      ).called(1);
    });
  });

  group('ReprogramarBloque', () {
    test(
      'mueve el bloque aunque el horario nuevo se pise con el viejo',
      () async {
        final actual = bloque('b1', inicio: a(13), fin: a(15));
        when(
          () => calendario.bloquesEntre(any(), any()),
        ).thenAnswer((_) async => [actual]);
        await ReprogramarBloque(bloques, calendario)(
          actual,
          inicio: a(14),
          fin: a(16),
        );
        verify(() => bloques.reprogramarBloque('b1', a(14), a(16))).called(1);
      },
    );

    test('no lo mueve encima de una clase', () async {
      final actual = bloque('b1', inicio: a(13), fin: a(15));
      await expectLater(
        ReprogramarBloque(bloques, calendario)(
          actual,
          inicio: a(9),
          fin: a(10),
        ),
        throwsA(isA<AppException>()),
      );
      verifyNever(() => bloques.reprogramarBloque(any(), any(), any()));
    });
  });

  group('DescartarBloque', () {
    test('descarta un bloque pendiente', () async {
      await DescartarBloque(bloques)(bloque('b1', inicio: a(13), fin: a(15)));
      verify(() => bloques.descartarBloque('b1')).called(1);
    });

    test('no descarta uno completado', () {
      final hecho = bloque(
        'b1',
        inicio: a(13),
        fin: a(15),
        estado: EstadoBloque.completado,
      );
      expect(
        () => DescartarBloque(bloques)(hecho),
        throwsA(isA<AppException>()),
      );
    });
  });
}
