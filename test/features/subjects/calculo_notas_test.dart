import 'package:flutter_test/flutter_test.dart';

import 'package:studyflow/features/subjects/domain/calculo_notas.dart';

void main() {
  const parcial = [
    NotaPonderada(nota: 4.0, porcentaje: 30),
    NotaPonderada(nota: 3.0, porcentaje: 20),
  ];

  group('sin notas', () {
    test('la nota acumulada es nula y el % evaluado es 0', () {
      expect(notaAcumulada(const []), isNull);
      expect(porcentajeEvaluado(const []), 0);
    });

    test('la nota que falta es la meta misma', () {
      expect(notaQueFalta(meta: 4.0, notas: const []), closeTo(4.0, 1e-9));
    });

    test('sin meta no hay nota que falte', () {
      expect(notaQueFalta(meta: null, notas: parcial), isNull);
    });
  });

  group('notas parciales', () {
    test('nota acumulada = Σ(nota×%) ÷ Σ%', () {
      expect(notaAcumulada(parcial), closeTo(3.6, 1e-9));
    });

    test('% evaluado suma los porcentajes calificados', () {
      expect(porcentajeEvaluado(parcial), 50);
    });

    test('nota que falta para la meta', () {
      // (4.0×100 − 180) ÷ (100 − 50) = 4.4
      final falta = notaQueFalta(meta: 4.0, notas: parcial);
      expect(falta, closeTo(4.4, 1e-9));
      expect(metaInalcanzable(falta), isFalse);
    });

    test('si ya aseguraste la meta la nota que falta es 0', () {
      const notas = [NotaPonderada(nota: 5.0, porcentaje: 60)];
      expect(notaQueFalta(meta: 3.0, notas: notas), 0);
      expect(notaQueFalta(meta: 2.0, notas: notas), 0);
    });

    test('con el 100 % evaluado no aplica', () {
      const notas = [
        NotaPonderada(nota: 4.0, porcentaje: 60),
        NotaPonderada(nota: 3.0, porcentaje: 40),
      ];
      expect(notaQueFalta(meta: 4.0, notas: notas), isNull);
      expect(notaAcumulada(notas), closeTo(3.6, 1e-9));
    });
  });

  group('meta inalcanzable', () {
    test('la nota que falta supera 5.0', () {
      // (4.5×100 − 180) ÷ 50 = 5.4
      final falta = notaQueFalta(meta: 4.5, notas: parcial);
      expect(falta, closeTo(5.4, 1e-9));
      expect(metaInalcanzable(falta), isTrue);
    });

    test('exactamente 5.0 todavía es alcanzable', () {
      // (4.3×100 − 180) ÷ 50 = 5.0
      final falta = notaQueFalta(meta: 4.3, notas: parcial);
      expect(falta, closeTo(5.0, 1e-9));
      expect(metaInalcanzable(falta), isFalse);
    });

    test('nulo no es inalcanzable', () {
      expect(metaInalcanzable(null), isFalse);
    });
  });

  group('promedio del semestre', () {
    test('se pondera por créditos', () {
      final promedio = promedioSemestre(const [
        NotaDeMateria(notaAcumulada: 4.0, creditos: 3),
        NotaDeMateria(notaAcumulada: 3.0, creditos: 1),
      ]);
      expect(promedio, closeTo(3.75, 1e-9));
    });

    test('las materias sin notas no cuentan', () {
      final promedio = promedioSemestre(const [
        NotaDeMateria(notaAcumulada: 4.0, creditos: 3),
        NotaDeMateria(notaAcumulada: null, creditos: 4),
      ]);
      expect(promedio, closeTo(4.0, 1e-9));
    });

    test('sin ninguna nota es nulo', () {
      expect(promedioSemestre(const []), isNull);
      expect(
        promedioSemestre(const [
          NotaDeMateria(notaAcumulada: null, creditos: 3),
        ]),
        isNull,
      );
    });
  });

  group('validaciones', () {
    test('los componentes deben sumar 100', () {
      expect(componentesSuman100(const [40, 35, 25]), isTrue);
      expect(componentesSuman100(const [40, 35, 20]), isFalse);
      expect(componentesSuman100(const []), isFalse);
    });

    test('la nota va de 0.0 a 5.0', () {
      expect(notaValida(0), isTrue);
      expect(notaValida(5), isTrue);
      expect(notaValida(5.1), isFalse);
      expect(notaValida(-0.1), isFalse);
    });
  });

  test('ResumenNotas junta todo', () {
    final r = ResumenNotas.desde(meta: 4.0, notas: parcial);
    expect(r.notaAcumulada, closeTo(3.6, 1e-9));
    expect(r.porcentajeEvaluado, 50);
    expect(r.notaQueFalta, closeTo(4.4, 1e-9));
    expect(r.metaInalcanzable, isFalse);
  });
}
