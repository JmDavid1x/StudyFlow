import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/assistant/domain/orden_respaldo.dart';

import 'fixtures.dart';

void main() {
  // Martes 10 de noviembre de 2026, 10:00 a. m.
  final ahora = DateTime(2026, 11, 10, 10);

  List<String> ids(List<ItemOrden> orden) => [
    for (final item in orden) item.actividad.id,
  ];

  group('ordenDeRespaldo', () {
    test('primero lo que vence antes', () {
      final orden = ordenDeRespaldo([
        actividad('jueves', fecha: DateTime(2026, 11, 12, 18)),
        actividad('hoy', fecha: DateTime(2026, 11, 10, 18)),
        actividad('manana', fecha: DateTime(2026, 11, 11, 18)),
      ], ahora);

      expect(ids(orden), ['hoy', 'manana', 'jueves']);
      expect([for (final item in orden) item.orden], [1, 2, 3]);
    });

    test('el mismo día va primero la que vale más porcentaje', () {
      final orden = ordenDeRespaldo([
        actividad('poco', fecha: DateTime(2026, 11, 12, 8), porcentaje: 5),
        actividad('mucho', fecha: DateTime(2026, 11, 12, 20), porcentaje: 30),
      ], ahora);

      expect(ids(orden), ['mucho', 'poco']);
    });

    test('con el mismo día y porcentaje, gana la prioridad alta', () {
      final orden = ordenDeRespaldo([
        actividad(
          'baja',
          fecha: DateTime(2026, 11, 12, 8),
          prioridad: Prioridad.baja,
        ),
        actividad(
          'alta',
          fecha: DateTime(2026, 11, 12, 20),
          prioridad: Prioridad.alta,
        ),
        actividad(
          'media',
          fecha: DateTime(2026, 11, 12, 9),
          prioridad: Prioridad.media,
        ),
      ], ahora);

      expect(ids(orden), ['alta', 'media', 'baja']);
    });

    test('deja por fuera las cerradas', () {
      final orden = ordenDeRespaldo([
        actividad(
          'hecha',
          fecha: DateTime(2026, 11, 10, 18),
          estado: EstadoActividad.completada,
        ),
        actividad(
          'presentado',
          fecha: DateTime(2026, 11, 11, 8),
          tipo: TipoActividad.examen,
          estado: EstadoActividad.presentado,
        ),
        actividad(
          'no',
          fecha: DateTime(2026, 11, 9, 8),
          estado: EstadoActividad.noEntregada,
        ),
        actividad(
          'abierta',
          fecha: DateTime(2026, 11, 12, 8),
          estado: EstadoActividad.enProgreso,
        ),
      ], ahora);

      expect(ids(orden), ['abierta']);
    });

    test('sin actividades devuelve una lista vacía', () {
      expect(ordenDeRespaldo(const [], ahora), isEmpty);
    });

    test('sugiere 2 horas para exámenes y proyectos y 1 para tareas', () {
      final orden = ordenDeRespaldo([
        actividad('t', fecha: DateTime(2026, 11, 10, 18)),
        actividad(
          'p',
          fecha: DateTime(2026, 11, 11, 18),
          tipo: TipoActividad.proyecto,
        ),
        actividad(
          'e',
          fecha: DateTime(2026, 11, 12, 8),
          tipo: TipoActividad.examen,
        ),
      ], ahora);

      expect([for (final item in orden) item.horasSugeridas], [1.0, 2.0, 2.0]);
    });
  });

  group('motivoDe', () {
    test('hoy y mañana dicen la hora', () {
      expect(
        motivoDe(actividad('a', fecha: DateTime(2026, 11, 10, 18)), ahora),
        'Vence hoy a las 6:00 p. m.',
      );
      expect(
        motivoDe(actividad('b', fecha: DateTime(2026, 11, 11, 23, 59)), ahora),
        'Vence mañana a las 11:59 p. m.',
      );
    });

    test('un examen "es" hoy', () {
      final examen = actividad(
        'e',
        fecha: DateTime(2026, 11, 10, 14),
        tipo: TipoActividad.examen,
      );
      expect(motivoDe(examen, ahora), 'Es hoy a las 2:00 p. m.');
    });

    test('más adelante dice cuánto vale', () {
      expect(
        motivoDe(
          actividad('a', fecha: DateTime(2026, 11, 13, 8), porcentaje: 30),
          ahora,
        ),
        'Vale 30 % de la nota',
      );
      expect(
        motivoDe(
          actividad('b', fecha: DateTime(2026, 11, 13, 8), porcentaje: 12.5),
          ahora,
        ),
        'Vale 12,5 % de la nota',
      );
    });

    test('si no vale nada, dice el día', () {
      expect(
        motivoDe(
          actividad('a', fecha: DateTime(2026, 11, 13, 8), porcentaje: 0),
          ahora,
        ),
        'Vence el vie 13 nov',
      );
    });

    test('si ya pasó, dice que venció', () {
      expect(
        motivoDe(actividad('a', fecha: DateTime(2026, 11, 9, 18)), ahora),
        'Venció el lun 9 nov a las 6:00 p. m.',
      );
    });
  });

  group('textos', () {
    test('la respuesta de respaldo trae la lista numerada', () {
      final orden = ordenDeRespaldo([
        actividad('a', fecha: DateTime(2026, 11, 10, 18)),
      ], ahora);
      expect(
        respuestaDeRespaldo(orden, sinConsultas: false),
        'No pude responderte con la IA, así que te dejo el orden de respaldo.\n'
        '1. Actividad a: Vence hoy a las 6:00 p. m.',
      );
    });

    test('sin pendientes dice qué hacer', () {
      expect(
        respuestaDeRespaldo(const [], sinConsultas: false),
        startsWith('No tienes actividades pendientes'),
      );
    });

    test('el resumen del plan nombra la primera actividad', () {
      final orden = ordenDeRespaldo([
        actividad('a', fecha: DateTime(2026, 11, 10, 18)),
        actividad('b', fecha: DateTime(2026, 11, 11, 18)),
        actividad('c', fecha: DateTime(2026, 11, 12, 18)),
      ], ahora);
      expect(
        resumenDelPlan(orden),
        'Empieza por Actividad a y sigue con 2 actividades más.',
      );
    });
  });
}
