import 'package:flutter_test/flutter_test.dart';

import 'package:studyflow/features/subjects/domain/componentes_por_defecto.dart';
import 'package:studyflow/features/subjects/domain/periodo_por_defecto.dart';
import 'package:studyflow/features/subjects/domain/simular_nota.dart';

import 'fixtures_materias.dart';

void main() {
  group('periodoPorDefecto', () {
    test('de julio en adelante es el semestre -2', () {
      final p = periodoPorDefecto(DateTime(2026, 11, 9));
      expect(p.nombre, '2026-2');
      expect(p.fechaInicio, DateTime(2026, 8, 3));
      expect(p.fechaFin, DateTime(2026, 12, 5));
    });

    test('antes de julio es el semestre -1', () {
      final p = periodoPorDefecto(DateTime(2027, 3, 1));
      expect(p.nombre, '2027-1');
      expect(p.fechaInicio.isBefore(p.fechaFin), isTrue);
    });
  });

  test('los componentes por defecto suman 100 %', () {
    expect(componentesPorDefecto.fold<int>(0, (s, c) => s + c.porcentaje), 100);
  });

  group('resumenConNota', () {
    final actividades = [
      actividadDePrueba('1', porcentaje: 30, nota: 4.0),
      actividadDePrueba('2', porcentaje: 20),
    ];

    test('agrega la nota de una actividad sin calificar', () {
      final r = resumenConNota(
        meta: 4.0,
        actividades: actividades,
        actividadId: '2',
        nota: 3.0,
      );
      // (4.0×30 + 3.0×20) ÷ 50
      expect(r.notaAcumulada, closeTo(3.6, 1e-9));
      expect(r.porcentajeEvaluado, 50);
    });

    test('reemplaza la nota de una actividad ya calificada', () {
      final r = resumenConNota(
        meta: null,
        actividades: actividades,
        actividadId: '1',
        nota: 5.0,
      );
      expect(r.notaAcumulada, closeTo(5.0, 1e-9));
      expect(r.porcentajeEvaluado, 30);
      expect(r.notaQueFalta, isNull);
    });

    test('no modifica la lista original', () {
      resumenConNota(
        meta: 4.0,
        actividades: actividades,
        actividadId: '2',
        nota: 1.0,
      );
      expect(actividades[1].tieneNota, isFalse);
    });
  });
}
