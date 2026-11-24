import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subscription/domain/planes_plus.dart';

import '../assistant/fixtures.dart';

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

  group('días de prueba', () {
    // La prueba de los fixtures va del 10 al 17 de noviembre.
    test('cuenta los días que faltan', () {
      expect(
        diasRestantesDePrueba(suscripcion(), DateTime(2026, 11, 10, 15)),
        7,
      );
      expect(diasRestantesDePrueba(suscripcion(), DateTime(2026, 11, 16)), 1);
      expect(diasRestantesDePrueba(suscripcion(), DateTime(2026, 11, 20)), 0);
    });

    test('una suscripción activa (ya pagada) no está en prueba', () {
      expect(
        diasRestantesDePrueba(
          suscripcion(estado: EstadoSuscripcion.activa),
          DateTime(2026, 11, 10),
        ),
        0,
      );
    });

    test('el texto cambia con los días', () {
      expect(textoDiasDePrueba(5), 'Te quedan 5 días de prueba');
      expect(textoDiasDePrueba(1), 'Te queda 1 día de prueba');
      expect(textoDiasDePrueba(0), 'Tu prueba gratis termina hoy');
    });
  });
}
