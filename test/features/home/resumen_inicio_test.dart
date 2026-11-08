import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/home/domain/resumen_inicio.dart';

import '../tasks/fixtures.dart';

void main() {
  // Miércoles 11 de noviembre de 2026, 10:00 a. m. La semana es del 9 al 15.
  final ahora = DateTime(2026, 11, 11, 10);

  ResumenInicio resumen({
    List<Actividad> actividades = const [],
    List<BloqueEstudio> bloques = const [],
    List<Notificacion> notificaciones = const [],
    DateTime? en,
  }) => calcularResumenInicio(
    actividades: actividades,
    bloques: bloques,
    notificaciones: notificaciones,
    ahora: en ?? ahora,
  );

  group('tarjetas', () {
    test('entregas de la semana cuenta tareas y proyectos, no exámenes', () {
      final r = resumen(
        actividades: [
          actividad('t1', fecha: DateTime(2026, 11, 9, 8), estado: EstadoActividad.completada),
          actividad('t2', fecha: DateTime(2026, 11, 13)),
          actividad('p1', tipo: TipoActividad.proyecto, fecha: DateTime(2026, 11, 15, 23)),
          actividad('e1', tipo: TipoActividad.examen, fecha: DateTime(2026, 11, 12)),
          actividad('fuera', fecha: DateTime(2026, 11, 16)),
        ],
      );
      expect(r.entregasSemana, 3);
    });

    test('próximo examen: el pendiente más cercano que todavía no pasa', () {
      final r = resumen(
        actividades: [
          actividad('ya-paso', tipo: TipoActividad.examen, fecha: DateTime(2026, 11, 11, 7)),
          actividad(
            'presentado',
            tipo: TipoActividad.examen,
            fecha: DateTime(2026, 11, 11, 14),
            estado: EstadoActividad.presentado,
          ),
          actividad('viernes', tipo: TipoActividad.examen, fecha: DateTime(2026, 11, 13, 7)),
          actividad('jueves', tipo: TipoActividad.examen, fecha: DateTime(2026, 11, 12, 7)),
        ],
      );
      expect(r.proximoExamen?.id, 'jueves');
    });

    test('sin exámenes pendientes no hay próximo examen', () {
      expect(resumen(actividades: [actividad('t1', fecha: DateTime(2026, 11, 12))]).proximoExamen, isNull);
    });

    test('horas planeadas: suma los bloques pendientes de la semana', () {
      final r = resumen(
        bloques: [
          bloque('b1', inicio: DateTime(2026, 11, 9, 14), duracion: const Duration(hours: 2)),
          bloque('b2', inicio: DateTime(2026, 11, 12, 16), duracion: const Duration(minutes: 90)),
          bloque('b3', inicio: DateTime(2026, 11, 15, 20), duracion: const Duration(minutes: 30)),
          bloque('hecho', inicio: DateTime(2026, 11, 10, 9), estado: EstadoBloque.completado),
          bloque('cancelado', inicio: DateTime(2026, 11, 10, 9), estado: EstadoBloque.cancelado),
          bloque('otra-semana', inicio: DateTime(2026, 11, 16, 9)),
        ],
      );
      expect(r.horasPlaneadas, const Duration(hours: 4));
    });
  });

  group('progreso semanal', () {
    test('completadas ÷ actividades con fecha en la semana', () {
      final r = resumen(
        actividades: [
          actividad('t1', fecha: DateTime(2026, 11, 9), estado: EstadoActividad.completada),
          actividad(
            'e1',
            tipo: TipoActividad.examen,
            fecha: DateTime(2026, 11, 10),
            estado: EstadoActividad.presentado,
          ),
          actividad('t2', fecha: DateTime(2026, 11, 10), estado: EstadoActividad.noEntregada),
          actividad('t3', fecha: DateTime(2026, 11, 14)),
          actividad('otra-semana', fecha: DateTime(2026, 11, 17), estado: EstadoActividad.completada),
        ],
      );
      expect(r.completadasSemana, 2);
      expect(r.totalSemana, 4);
      expect(r.progresoSemanal, 0.5);
    });

    test('sin actividades el progreso es 0 y está vacío', () {
      final r = resumen();
      expect(r.progresoSemanal, 0);
      expect(r.sinActividades, isTrue);
    });
  });

  group('listas', () {
    test('prioridades de hoy: sin cerrar, alta primero y luego por hora', () {
      final r = resumen(
        actividades: [
          actividad('media-tarde', fecha: DateTime(2026, 11, 11, 16)),
          actividad('alta-noche', fecha: DateTime(2026, 11, 11, 23, 59), prioridad: Prioridad.alta),
          actividad('baja-manana', fecha: DateTime(2026, 11, 11, 12), prioridad: Prioridad.baja),
          actividad('media-temprano', fecha: DateTime(2026, 11, 11, 11)),
          actividad('hecha', fecha: DateTime(2026, 11, 11, 18), estado: EstadoActividad.completada),
          actividad('manana', fecha: DateTime(2026, 11, 12, 8)),
        ],
      );
      expect([for (final a in r.prioridadesHoy) a.id], ['alta-noche', 'media-temprano', 'media-tarde', 'baja-manana']);
    });

    test('próximas: sin cerrar en los siguientes 7 días, por fecha', () {
      final r = resumen(
        actividades: [
          actividad('hoy', fecha: DateTime(2026, 11, 11, 18)),
          actividad('lunes', fecha: DateTime(2026, 11, 16, 8)),
          actividad('jueves', fecha: DateTime(2026, 11, 12, 8)),
          actividad('hecha', fecha: DateTime(2026, 11, 13), estado: EstadoActividad.completada),
          actividad('dia-7', fecha: DateTime(2026, 11, 18, 23, 59)),
          actividad('dia-8', fecha: DateTime(2026, 11, 19, 0, 1)),
        ],
      );
      expect([for (final a in r.proximas) a.id], ['jueves', 'lunes', 'dia-7']);
    });

    test('el domingo "Próximas" muestra lo de la semana siguiente', () {
      final domingo = DateTime(2026, 11, 15, 20);
      final r = resumen(
        en: domingo,
        actividades: [actividad('lunes', fecha: DateTime(2026, 11, 16, 8))],
      );
      expect([for (final a in r.proximas) a.id], ['lunes']);
      expect(r.sinActividades, isFalse);
    });
  });

  group('avisos', () {
    test('bloque pendiente de ayer: el último que quedó sin hacer', () {
      final r = resumen(
        bloques: [
          bloque('ayer-temprano', inicio: DateTime(2026, 11, 10, 8)),
          bloque('ayer-tarde', inicio: DateTime(2026, 11, 10, 17)),
          bloque('ayer-hecho', inicio: DateTime(2026, 11, 10, 20), estado: EstadoBloque.completado),
          bloque('hoy', inicio: DateTime(2026, 11, 11, 8)),
          bloque('anteayer', inicio: DateTime(2026, 11, 9, 8)),
        ],
      );
      expect(r.bloquePendienteAyer?.id, 'ayer-tarde');
    });

    test('sin bloques pendientes de ayer no hay aviso', () {
      final r = resumen(bloques: [bloque('hoy', inicio: DateTime(2026, 11, 11, 8))]);
      expect(r.bloquePendienteAyer, isNull);
    });

    test('novedades: sin leer y ya programadas', () {
      final r = resumen(
        notificaciones: [
          notificacion('n1', programadaPara: DateTime(2026, 11, 11, 7)),
          notificacion('n2', programadaPara: DateTime(2026, 11, 10, 7), leidaEn: DateTime(2026, 11, 10, 8)),
          notificacion('futura', programadaPara: DateTime(2026, 11, 12, 7)),
        ],
      );
      expect(r.notificacionesSinLeer, 1);
      expect(r.hayNovedades, isTrue);
    });
  });

  group('RangoInicio', () {
    test('un miércoles pide del lunes al miércoles siguiente', () {
      final rango = RangoInicio(ahora);
      expect(rango.desde, DateTime(2026, 11, 9));
      expect(rango.hasta, DateTime(2026, 11, 19));
    });

    test('un lunes empieza desde ayer (domingo) para el aviso del bloque', () {
      final rango = RangoInicio(DateTime(2026, 11, 16, 9));
      expect(rango.desde, DateTime(2026, 11, 15));
      expect(rango.hasta, DateTime(2026, 11, 24));
    });
  });
}
