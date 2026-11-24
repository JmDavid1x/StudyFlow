import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/core/realtime/cambios_en_vivo.dart';
import 'package:studyflow/features/calendar/calendar_di.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/calendar/ui/screens/calendar_screen.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';
import 'package:studyflow/features/study_blocks/study_blocks_di.dart';

class _FalsoCalendario extends Mock implements CalendarRepository {}

class _FalsoBloques extends Mock implements StudyBlocksRepository {}

/// Cambios en vivo falsos: el test decide cuándo "cambió algo en Supabase".
class _CambiosFalsos implements CambiosEnVivo {
  final avisos = StreamController<void>.broadcast();
  Set<String>? tablasPedidas;

  @override
  Stream<void> de(Set<String> tablas) {
    tablasPedidas = tablas;
    return avisos.stream;
  }
}

/// La pestaña Calendario se recarga sola cuando cambian las actividades o
/// los bloques en Supabase (RecargarEnVivo), sin que el usuario toque nada.
void main() {
  late _FalsoCalendario calendario;
  late _CambiosFalsos cambios;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(DateTime(2026));
  });

  setUp(() async {
    await sl.reset();
    registrarCalendar(sl);
    registrarStudyBlocks(sl);

    calendario = _FalsoCalendario();
    cambios = _CambiosFalsos();
    await sl.unregister<CalendarRepository>();
    await sl.unregister<StudyBlocksRepository>();
    sl.registerSingleton<CalendarRepository>(calendario);
    sl.registerSingleton<StudyBlocksRepository>(_FalsoBloques());
    sl.registerSingleton<CambiosEnVivo>(cambios);

    when(() => calendario.horarios()).thenAnswer((_) async => []);
    when(
      () => calendario.actividadesEntre(any(), any()),
    ).thenAnswer((_) async => []);
    when(
      () => calendario.bloquesEntre(any(), any()),
    ).thenAnswer((_) async => []);
  });

  tearDown(() => sl.reset());

  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: CalendarScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets('escucha las tablas de actividades y bloques', (tester) async {
    await abrir(tester);
    expect(cambios.tablasPedidas, {'actividades', 'bloques_estudio'});
    verify(() => calendario.bloquesEntre(any(), any())).called(1);
  });

  testWidgets('si llega un cambio, recarga la semana sola', (tester) async {
    await abrir(tester);
    clearInteractions(calendario);

    cambios.avisos.add(null);
    await tester.pumpAndSettle();

    verify(() => calendario.actividadesEntre(any(), any())).called(1);
    verify(() => calendario.bloquesEntre(any(), any())).called(1);
  });

  testWidgets('al salir de la pestaña deja de escuchar', (tester) async {
    await abrir(tester);
    expect(cambios.avisos.hasListener, isTrue);

    await tester.pumpWidget(const SizedBox());
    expect(cambios.avisos.hasListener, isFalse);
  });
}
