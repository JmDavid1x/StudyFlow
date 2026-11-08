import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';
import 'package:studyflow/features/task_form/ui/bloc/task_form_cubit.dart';
import 'package:studyflow/features/task_form/ui/screens/new_task_screen.dart';

class _MockRepositorio extends Mock implements TaskFormRepository {}

void main() {
  const proyecto = ComponenteNota(
    id: 'c2',
    materiaId: 'm1',
    nombre: 'Proyecto',
    porcentaje: 40,
  );
  const moviles = Materia(
    id: 'm1',
    periodoId: 'p1',
    nombre: 'Aplicaciones Móviles',
    profesor: 'Prof. Andrés Ruiz',
    creditos: 3,
    colorHex: '#A78BFA',
    componentes: [proyecto],
  );

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repositorio = _MockRepositorio();
    when(
      () => repositorio.materiasConComponentes(),
    ).thenAnswer((_) async => [moviles]);
    when(() => repositorio.porcentajesAsignados()).thenAnswer(
      (_) async => [(actividadId: 'a1', componenteId: 'c2', porcentaje: 15)],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => TaskFormCubit(repositorio)..cargar(),
          child: const NewTaskScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra las materias reales en el selector', (tester) async {
    await abrir(tester);
    expect(find.text('Aplicaciones Móviles'), findsOneWidget);
    expect(find.text('Elige primero la materia.'), findsOneWidget);
  });

  testWidgets('al elegir la materia salen sus partes y lo que queda', (
    tester,
  ) async {
    await abrir(tester);
    await tester.tap(find.text('Aplicaciones Móviles'));
    await tester.pumpAndSettle();
    expect(find.text('Proyecto'), findsWidgets);

    await tester.tap(find.text('40 %'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Proyecto vale 40 %: esta tarea usa 0 % y quedan 25 % sin asignar.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('no deja guardar sin los datos obligatorios', (tester) async {
    await abrir(tester);
    await tester.ensureVisible(find.text('Guardar tarea'));
    await tester.tap(find.text('Guardar tarea'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe el título'), findsOneWidget);
    expect(find.text('Elige la materia'), findsOneWidget);
  });
}
