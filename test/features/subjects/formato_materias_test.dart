import 'package:flutter_test/flutter_test.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subjects/ui/widgets/formato_materias.dart';

HorarioClase _h(int dia, Hora inicio) => HorarioClase(
  id: '$dia',
  materiaId: 'm1',
  diaSemana: dia,
  horaInicio: inicio,
  horaFin: Hora(inicio.hora + 2, 0),
);

void main() {
  test('horaTexto en formato 12 horas', () {
    expect(horaTexto(const Hora(7, 0)), '7:00 a. m.');
    expect(horaTexto(const Hora(18, 30)), '6:30 p. m.');
    expect(horaTexto(const Hora(0, 5)), '12:05 a. m.');
    expect(horaTexto(const Hora(12, 0)), '12:00 p. m.');
  });

  test('horarioTexto junta los días a la misma hora', () {
    expect(
      horarioTexto([_h(4, const Hora(7, 0)), _h(2, const Hora(7, 0))]),
      'Mar y jue, 7:00 a. m.',
    );
    expect(horarioTexto([_h(1, const Hora(9, 0))]), 'Lun, 9:00 a. m.');
    expect(horarioTexto(const []), isNull);
  });

  test('fechaCorta y notaTexto', () {
    expect(fechaCorta(DateTime(2026, 9, 21)), 'lun 21/09');
    expect(notaTexto(4), '4.0');
    expect(notaTexto(null), '–');
  });
}
