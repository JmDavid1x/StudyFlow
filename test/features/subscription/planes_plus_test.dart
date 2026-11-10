import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subscription/domain/planes_plus.dart';

void main() {
  test('precio según la periodicidad', () {
    expect(precioPlus(Periodicidad.mensual), 9900);
    expect(precioPlus(Periodicidad.semestral), 39900);
  });

  test('los pesos se escriben con punto de miles', () {
    expect(formatoCop(0), 'COP 0');
    expect(formatoCop(9900), 'COP 9.900');
    expect(formatoCop(39900), 'COP 39.900');
    expect(formatoCop(1250000), 'COP 1.250.000');
  });

  test('la prueba dura 7 días, aunque cambie de mes', () {
    expect(finDePrueba(DateTime(2026, 11, 10, 15)), DateTime(2026, 11, 17));
    expect(finDePrueba(DateTime(2026, 11, 28)), DateTime(2026, 12, 5));
  });
}
