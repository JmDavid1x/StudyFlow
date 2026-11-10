import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/features/tasks/domain/semana.dart';

void main() {
  test('la semana va de lunes a domingo', () {
    // Miércoles 11 de noviembre de 2026.
    final miercoles = DateTime(2026, 11, 11, 15, 30);
    expect(inicioDeSemana(miercoles), DateTime(2026, 11, 9));
    expect(finDeSemana(miercoles), DateTime(2026, 11, 16));
  });

  test('el domingo sigue en la misma semana y el lunes empieza otra', () {
    expect(inicioDeSemana(DateTime(2026, 11, 15, 23, 59)), DateTime(2026, 11, 9));
    expect(inicioDeSemana(DateTime(2026, 11, 16)), DateTime(2026, 11, 16));
  });

  test('cruza el cambio de mes', () {
    // Martes 1 de diciembre: el lunes es 30 de noviembre.
    expect(inicioDeSemana(DateTime(2026, 12, 1)), DateTime(2026, 11, 30));
  });

  test('estaEntre incluye el inicio y excluye el final', () {
    final desde = DateTime(2026, 11, 9);
    final hasta = DateTime(2026, 11, 16);
    expect(estaEntre(desde, desde, hasta), isTrue);
    expect(estaEntre(hasta, desde, hasta), isFalse);
  });
}
