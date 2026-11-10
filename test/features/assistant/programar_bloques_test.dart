import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/assistant/domain/orden_respaldo.dart';
import 'package:studyflow/features/assistant/domain/programar_bloques.dart';

import 'fixtures.dart';

void main() {
  // Martes 10 de noviembre de 2026 (weekday 2), 10:10 a. m.
  final ahora = DateTime(2026, 11, 10, 10, 10);

  ItemOrden item(Actividad a, {double horas = 1}) =>
      ItemOrden(actividad: a, orden: 1, motivo: '', horasSugeridas: horas);

  test('empieza en la siguiente media hora libre', () {
    final bloques = programarBloques(
      orden: [item(actividad('a', fecha: DateTime(2026, 11, 12, 18)))],
      horarios: const [],
      ocupados: const [],
      ahora: ahora,
    );

    expect(bloques.single.inicio, DateTime(2026, 11, 10, 10, 30));
    expect(bloques.single.fin, DateTime(2026, 11, 10, 11, 30));
  });

  test('no se cruza con una clase', () {
    final bloques = programarBloques(
      orden: [
        item(actividad('a', fecha: DateTime(2026, 11, 12, 18)), horas: 2),
      ],
      horarios: [clase(DateTime.tuesday, 11, 13)],
      ocupados: const [],
      ahora: ahora,
    );

    // 10:30 a 12:30 chocaría con la clase de 11 a 1: empieza a la 1.
    expect(bloques.single.inicio, DateTime(2026, 11, 10, 13));
  });

  test('no se cruza con otros bloques pendientes ni entre sí', () {
    final bloques = programarBloques(
      orden: [
        item(actividad('a', fecha: DateTime(2026, 11, 12, 18))),
        item(actividad('b', fecha: DateTime(2026, 11, 12, 18))),
      ],
      horarios: const [],
      ocupados: [bloque('x', inicio: DateTime(2026, 11, 10, 10, 30))],
      ahora: ahora,
    );

    expect(bloques[0].inicio, DateTime(2026, 11, 10, 11, 30));
    expect(bloques[1].inicio, DateTime(2026, 11, 10, 12, 30));
  });

  test('si no cabe hoy, pasa al día siguiente desde las 8', () {
    final tarde = DateTime(2026, 11, 10, 20, 10);
    final bloques = programarBloques(
      orden: [
        item(actividad('a', fecha: DateTime(2026, 11, 12, 18)), horas: 2),
      ],
      horarios: const [],
      ocupados: const [],
      ahora: tarde,
    );

    expect(bloques.single.inicio, DateTime(2026, 11, 11, horaInicioEstudio));
  });

  test(
    'si no alcanza antes de la fecha límite, la actividad queda sin bloque',
    () {
      final bloques = programarBloques(
        orden: [
          item(actividad('a', fecha: DateTime(2026, 11, 10, 11)), horas: 2),
        ],
        horarios: const [],
        ocupados: const [],
        ahora: ahora,
      );

      expect(bloques, isEmpty);
    },
  );
}
