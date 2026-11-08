import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/calendar/domain/agenda_del_dia.dart';

import 'fixtures.dart';

void main() {
  group('inicioDeSemana', () {
    test('devuelve el lunes a las 00:00', () {
      expect(
        inicioDeSemana(DateTime(2026, 11, 11, 15, 30)),
        DateTime(2026, 11, 9),
      );
      expect(inicioDeSemana(DateTime(2026, 11, 15, 23)), DateTime(2026, 11, 9));
      expect(inicioDeSemana(lunes), lunes);
    });
  });

  group('agendaDelDia', () {
    final calculoLunes = clase(
      'Cálculo Integral',
      1,
      const Hora(9, 0),
      const Hora(11, 0),
    );
    final movilesMartes = clase(
      'Aplicaciones Móviles',
      2,
      const Hora(7, 0),
      const Hora(9, 0),
    );

    test('junta clases, bloques y entregas del día ordenados por hora', () {
      final agenda = agendaDelDia(
        lunes,
        horarios: [calculoLunes, movilesMartes],
        actividades: [
          actividad(
            'taller',
            fecha: lunes.add(const Duration(hours: 23, minutes: 59)),
          ),
          actividad('lectura', fecha: lunes.add(const Duration(hours: 18))),
          actividad('otro-dia', fecha: martes.add(const Duration(hours: 10))),
        ],
        bloques: [
          bloque(
            'b1',
            inicio: lunes.add(const Duration(hours: 13)),
            fin: lunes.add(const Duration(hours: 15)),
          ),
        ],
      );

      expect(agenda.map((e) => e.inicio.hour), [9, 13, 18, 23]);
      expect(agenda[0], isA<ClaseEnAgenda>());
      expect(agenda[1], isA<BloqueEnAgenda>());
      expect((agenda[2] as EntregaEnAgenda).actividad.id, 'lectura');
      expect((agenda[3] as EntregaEnAgenda).actividad.id, 'taller');
    });

    test('la clase toma la fecha del día pedido', () {
      final agenda = agendaDelDia(
        lunes,
        horarios: [calculoLunes],
        actividades: const [],
        bloques: const [],
      );
      final entrada = agenda.single as ClaseEnAgenda;
      expect(entrada.inicio, DateTime(2026, 11, 9, 9));
      expect(entrada.fin, DateTime(2026, 11, 9, 11));
    });

    test('no muestra bloques descartados ni cancelados', () {
      final a = lunes.add(const Duration(hours: 13));
      final b = lunes.add(const Duration(hours: 14));
      final agenda = agendaDelDia(
        lunes,
        horarios: const [],
        actividades: const [],
        bloques: [
          bloque('pendiente', inicio: a, fin: b),
          bloque('hecho', inicio: a, fin: b, estado: EstadoBloque.completado),
          bloque(
            'descartado',
            inicio: a,
            fin: b,
            estado: EstadoBloque.descartado,
          ),
          bloque(
            'cancelado',
            inicio: a,
            fin: b,
            estado: EstadoBloque.cancelado,
          ),
        ],
      );
      expect(agenda.map((e) => (e as BloqueEnAgenda).bloque.id), [
        'pendiente',
        'hecho',
      ]);
    });

    test(
      'a la misma hora va primero la clase, luego el bloque y al final la entrega',
      () {
        final nueve = lunes.add(const Duration(hours: 9));
        final agenda = agendaDelDia(
          lunes,
          horarios: [calculoLunes],
          actividades: [actividad('a', fecha: nueve)],
          bloques: [
            bloque(
              'b',
              inicio: nueve,
              fin: nueve.add(const Duration(hours: 1)),
            ),
          ],
        );
        expect(agenda.map((e) => e.runtimeType), [
          ClaseEnAgenda,
          BloqueEnAgenda,
          EntregaEnAgenda,
        ]);
      },
    );

    test('un día sin nada da una agenda vacía', () {
      final domingo = DateTime(2026, 11, 15);
      expect(
        agendaDelDia(
          domingo,
          horarios: [calculoLunes],
          actividades: const [],
          bloques: const [],
        ),
        isEmpty,
      );
    });
  });

  group('tienePendientes', () {
    final diez = lunes.add(const Duration(hours: 10));

    test('sí con una actividad sin cerrar o un bloque pendiente', () {
      expect(
        tienePendientes(
          lunes,
          actividades: [actividad('a', fecha: diez)],
          bloques: const [],
        ),
        isTrue,
      );
      expect(
        tienePendientes(
          lunes,
          actividades: const [],
          bloques: [
            bloque('b', inicio: diez, fin: diez.add(const Duration(hours: 1))),
          ],
        ),
        isTrue,
      );
    });

    test('no si todo está cerrado o completado', () {
      expect(
        tienePendientes(
          lunes,
          actividades: [
            actividad('a', fecha: diez, estado: EstadoActividad.completada),
            actividad(
              'e',
              fecha: diez,
              tipo: TipoActividad.examen,
              estado: EstadoActividad.presentado,
            ),
          ],
          bloques: [
            bloque(
              'b',
              inicio: diez,
              fin: diez.add(const Duration(hours: 1)),
              estado: EstadoBloque.completado,
            ),
          ],
        ),
        isFalse,
      );
    });

    test('no cuenta lo de otro día', () {
      expect(
        tienePendientes(
          martes,
          actividades: [actividad('a', fecha: diez)],
          bloques: const [],
        ),
        isFalse,
      );
    });
  });
}
