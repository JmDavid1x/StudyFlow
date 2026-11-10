import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studyflow/features/subjects/domain/resumen_semestre.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';
import 'package:studyflow/features/subjects/domain/usecases/obtener_resumen_semestre.dart';

import 'fixtures_materias.dart';

class _MockRepo extends Mock implements SubjectsRepository {}

void main() {
  late _MockRepo repo;

  setUp(() => repo = _MockRepo());

  test('sin materias devuelve un resumen vacío', () async {
    when(() => repo.materiasDelPeriodo()).thenAnswer((_) async => []);

    final resumen = await ObtenerResumenSemestre(repo)();

    expect(resumen.vacio, isTrue);
    expect(resumen.promedio, isNull);
  });

  test('calcula nota por materia y promedio ponderado por créditos', () async {
    final a = materiaDePrueba(id: 'a', creditos: 3, meta: 4.0);
    final b = materiaDePrueba(id: 'b', creditos: 1, meta: 4.0);
    final c = materiaDePrueba(id: 'c', creditos: 4); // sin notas: no cuenta
    when(() => repo.materiasDelPeriodo()).thenAnswer((_) async => [a, b, c]);
    when(() => repo.actividadesConNota('a')).thenAnswer(
      (_) async => [actividadDePrueba('1', porcentaje: 50, nota: 4.0)],
    );
    when(() => repo.actividadesConNota('b')).thenAnswer(
      (_) async => [actividadDePrueba('2', porcentaje: 50, nota: 3.0)],
    );
    when(
      () => repo.actividadesConNota('c'),
    ).thenAnswer((_) async => [actividadDePrueba('3')]);

    final resumen = await ObtenerResumenSemestre(repo)();

    expect(resumen.materias.map((m) => m.resumen.notaAcumulada), [
      4.0,
      3.0,
      null,
    ]);
    expect(resumen.promedio, closeTo(3.75, 1e-9));
  });

  test('resumenDeComponentes: sin nota, completo y parcial', () {
    final componentes = [
      componenteDePrueba('c1', nombre: 'Talleres'),
      componenteDePrueba('c2', nombre: 'Proyecto'),
      componenteDePrueba('c3', nombre: 'Parciales'),
    ];
    final actividades = [
      actividadDePrueba('1', componenteId: 'c1', nota: 4.0),
      actividadDePrueba('2', componenteId: 'c1', nota: 5.0),
      actividadDePrueba('3', componenteId: 'c2'),
      actividadDePrueba('4', componenteId: 'c3', nota: 3.0),
      actividadDePrueba('5', componenteId: 'c3'),
    ];

    final r = resumenDeComponentes(componentes, actividades);

    expect(r[0].nota, closeTo(4.5, 1e-9));
    expect((r[0].calificadas, r[0].total), (2, 2));
    expect(r[1].nota, isNull);
    expect((r[2].calificadas, r[2].total), (1, 2));
  });
}
