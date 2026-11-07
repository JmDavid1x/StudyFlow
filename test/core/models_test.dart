import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/data/data.dart';

void main() {
  group('Actividad', () {
    final fila = {
      'id': 'a1',
      'componente_id': 'c1',
      'titulo': 'Taller 3: consultas SQL',
      'tipo': 'tarea',
      'fecha_limite': '2026-11-10T04:59:00+00:00',
      'canal_entrega': 'intu',
      'lugar': null,
      'porcentaje': 15,
      'prioridad': 'alta',
      'estado': 'por_hacer',
      'recordatorio': true,
      'notas': null,
      'completada_en': null,
      'creado_en': '2026-11-01T12:00:00+00:00',
      'actualizado_en': '2026-11-01T12:00:00+00:00',
      'componentes_nota': {
        'id': 'c1',
        'nombre': 'Talleres',
        'materia_id': 'm1',
        'materias': {'id': 'm1', 'nombre': 'Bases de Datos', 'color': '#2DD4BF'},
      },
    };

    test('lee la fila con su materia anidada', () {
      final actividad = Actividad.fromMap(fila);
      expect(actividad.tipo, TipoActividad.tarea);
      expect(actividad.estado, EstadoActividad.porHacer);
      expect(actividad.canalEntrega, CanalEntrega.intu);
      expect(actividad.porcentaje, 15.0);
      expect(actividad.materiaNombre, 'Bases de Datos');
      expect(actividad.componenteNombre, 'Talleres');
    });

    test('toInsert usa los valores de la base', () {
      final mapa = Actividad.fromMap(fila).toInsert();
      expect(mapa['estado'], 'por_hacer');
      expect(mapa['tipo'], 'tarea');
      expect(mapa.containsKey('id'), isFalse);
    });

    test('está vencida si pasó la fecha y no está cerrada', () {
      final actividad = Actividad.fromMap(fila);
      expect(actividad.estaVencida(DateTime.utc(2026, 11, 11)), isTrue);
      expect(actividad.copyWith(estado: EstadoActividad.completada).estaVencida(DateTime.utc(2026, 11, 11)), isFalse);
    });
  });

  test('Materia lee horarios, componentes y color', () {
    final materia = Materia.fromMap(const {
      'id': 'm1',
      'periodo_id': 'p1',
      'nombre': 'Aplicaciones Móviles',
      'profesor': 'Andrés Ruiz',
      'creditos': 3,
      'color': '#A78BFA',
      'meta_nota': 4.4,
      'creado_en': '2026-11-01T12:00:00+00:00',
      'horarios_clase': [
        {'id': 'h1', 'materia_id': 'm1', 'dia_semana': 2, 'hora_inicio': '07:00:00', 'hora_fin': '09:00:00', 'salon': '401C'},
      ],
      'componentes_nota': [
        {'id': 'c1', 'materia_id': 'm1', 'nombre': 'Proyecto', 'porcentaje': 40},
      ],
    });
    expect(materia.horarios.single.horaInicio, const Hora(7, 0));
    expect(materia.componentes.single.porcentaje, 40.0);
    expect(materia.color.toARGB32(), 0xFFA78BFA);
  });

  test('Hora va y vuelve de la base', () {
    expect(Hora.fromDb('18:30:00').toDb(), '18:30');
    expect(const Hora(7, 0).compareTo(const Hora(9, 0)), lessThan(0));
  });

  test('Bloque detecta cruces', () {
    final bloque = BloqueEstudio(
      id: 'b1',
      actividadId: 'a1',
      inicio: DateTime(2026, 11, 9, 14),
      fin: DateTime(2026, 11, 9, 16),
      estado: EstadoBloque.pendiente,
    );
    expect(bloque.seCruzaCon(DateTime(2026, 11, 9, 15), DateTime(2026, 11, 9, 17)), isTrue);
    expect(bloque.seCruzaCon(DateTime(2026, 11, 9, 16), DateTime(2026, 11, 9, 17)), isFalse);
  });
}
