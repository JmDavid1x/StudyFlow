import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studyflow/features/subjects/domain/calculo_notas.dart';
import 'package:studyflow/features/subjects/ui/widgets/class_schedule.dart';
import 'package:studyflow/features/subjects/ui/widgets/conversiones_materia.dart';
import 'package:studyflow/features/subjects/ui/widgets/formato_materias.dart';

void main() {
  test('colorAHex', () {
    expect(colorAHex(const Color(0xFFA78BFA)), '#A78BFA');
    expect(colorAHex(const Color(0xFF00FF0A)), '#00FF0A');
  });

  test('diaSemanaDe', () {
    expect(diaSemanaDe('Lunes'), 1);
    expect(diaSemanaDe('Miércoles'), 3);
    expect(diaSemanaDe('Sábado'), 6);
  });

  test('horarioDesdeClase convierte día, horas y salón', () {
    const clase = ClassSchedule(
      day: 'Martes',
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 9, minute: 30),
      room: 'Salón 401C',
    );
    final h = horarioDesdeClase(clase);
    expect(h.diaSemana, 2);
    expect(h.horaInicio.toDb(), '07:00');
    expect(h.horaFin.toDb(), '09:30');
    expect(h.salon, 'Salón 401C');
  });

  test('un salón vacío se guarda como nulo', () {
    const clase = ClassSchedule(
      day: 'Lunes',
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 10, minute: 0),
    );
    expect(horarioDesdeClase(clase).salon, isNull);
  });

  group('textoParaLaMeta', () {
    const parcial = [
      NotaPonderada(nota: 4.0, porcentaje: 30),
      NotaPonderada(nota: 3.0, porcentaje: 20),
    ];

    test('sin meta no hay texto', () {
      expect(
        textoParaLaMeta(
          meta: null,
          resumen: ResumenNotas.desde(meta: null, notas: parcial),
        ),
        isNull,
      );
    });

    test('lo que falta', () {
      final r = ResumenNotas.desde(meta: 4.0, notas: parcial);
      expect(
        textoParaLaMeta(meta: 4.0, resumen: r),
        'Necesitas 4.4 en el 50 % que falta',
      );
    });

    test('meta inalcanzable', () {
      final r = ResumenNotas.desde(meta: 4.5, notas: parcial);
      expect(
        textoParaLaMeta(meta: 4.5, resumen: r),
        contains('no es alcanzable'),
      );
    });

    test('meta asegurada y materia terminada', () {
      final asegurada = ResumenNotas.desde(
        meta: 2.0,
        notas: const [NotaPonderada(nota: 5.0, porcentaje: 60)],
      );
      expect(
        textoParaLaMeta(meta: 2.0, resumen: asegurada),
        'Ya aseguraste tu meta',
      );
      final completa = ResumenNotas.desde(
        meta: 4.0,
        notas: const [NotaPonderada(nota: 4.0, porcentaje: 100)],
      );
      expect(
        textoParaLaMeta(meta: 4.0, resumen: completa),
        'Ya evaluaste toda la materia',
      );
    });
  });
}
