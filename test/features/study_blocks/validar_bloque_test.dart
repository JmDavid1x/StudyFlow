import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/study_blocks/domain/validar_bloque.dart';

import '../calendar/fixtures.dart';

void main() {
  final calculoLunes = clase(
    'Cálculo Integral',
    1,
    const Hora(9, 0),
    const Hora(11, 0),
  );
  DateTime a(int hora, [int minuto = 0]) => DateTime(2026, 11, 9, hora, minuto);

  group('validarBloque', () {
    test('un horario libre se puede guardar', () {
      expect(
        validarBloque(
          inicio: a(13),
          fin: a(15),
          horarios: [calculoLunes],
          bloques: const [],
        ),
        isNull,
      );
    });

    test('no deja guardar si el fin no es después del inicio', () {
      expect(
        validarBloque(
          inicio: a(15),
          fin: a(15),
          horarios: const [],
          bloques: const [],
        ),
        isNotNull,
      );
      expect(
        validarBloque(
          inicio: a(15),
          fin: a(14),
          horarios: const [],
          bloques: const [],
        ),
        isNotNull,
      );
    });

    test('se cruza con una clase', () {
      final mensaje = validarBloque(
        inicio: a(10),
        fin: a(12),
        horarios: [calculoLunes],
        bloques: const [],
      );
      expect(
        mensaje,
        'Se cruza con tu clase de Cálculo Integral (9:00 a. m. – 11:00 a. m.).',
      );
    });

    test('pegado a la clase no es cruce', () {
      expect(
        validarBloque(
          inicio: a(7),
          fin: a(9),
          horarios: [calculoLunes],
          bloques: const [],
        ),
        isNull,
      );
      expect(
        validarBloque(
          inicio: a(11),
          fin: a(12),
          horarios: [calculoLunes],
          bloques: const [],
        ),
        isNull,
      );
    });

    test('la clase de otro día de la semana no cuenta', () {
      final martes = DateTime(2026, 11, 10, 10);
      expect(
        validarBloque(
          inicio: martes,
          fin: martes.add(const Duration(hours: 1)),
          horarios: [calculoLunes],
          bloques: const [],
        ),
        isNull,
      );
    });

    test('se cruza con otro bloque pendiente', () {
      final otro = bloque('b1', inicio: a(13), fin: a(15));
      final mensaje = validarBloque(
        inicio: a(14),
        fin: a(16),
        horarios: const [],
        bloques: [otro],
      );
      expect(
        mensaje,
        'Se cruza con tu bloque "Taller b1" (1:00 p. m. – 3:00 p. m.).',
      );
    });

    test('los bloques completados o descartados no estorban', () {
      final bloques = [
        bloque(
          'hecho',
          inicio: a(13),
          fin: a(15),
          estado: EstadoBloque.completado,
        ),
        bloque(
          'descartado',
          inicio: a(13),
          fin: a(15),
          estado: EstadoBloque.descartado,
        ),
      ];
      expect(
        validarBloque(
          inicio: a(13),
          fin: a(15),
          horarios: const [],
          bloques: bloques,
        ),
        isNull,
      );
    });

    test('al reprogramar, el bloque no choca consigo mismo', () {
      final mismo = bloque('b1', inicio: a(13), fin: a(15));
      expect(
        validarBloque(
          inicio: a(14),
          fin: a(16),
          horarios: const [],
          bloques: [mismo],
          ignorar: 'b1',
        ),
        isNull,
      );
    });
  });

  group('buscarCruce', () {
    test('dice si es clase o bloque', () {
      expect(
        buscarCruce(
          inicio: a(10),
          fin: a(11),
          horarios: [calculoLunes],
          bloques: const [],
        )!.esClase,
        isTrue,
      );
      final otro = bloque('b1', inicio: a(13), fin: a(15));
      expect(
        buscarCruce(
          inicio: a(14),
          fin: a(15),
          horarios: const [],
          bloques: [otro],
        )!.esClase,
        isFalse,
      );
    });
  });

  test('formatoHora escribe como el resto de la app', () {
    expect(formatoHora(a(0)), '12:00 a. m.');
    expect(formatoHora(a(9, 5)), '9:05 a. m.');
    expect(formatoHora(a(12)), '12:00 p. m.');
    expect(formatoHora(a(23, 59)), '11:59 p. m.');
  });
}
