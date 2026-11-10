import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/tasks/domain/textos_actividad.dart';

import 'fixtures.dart';

void main() {
  // Miércoles 11 nov 2026, 10:00 a. m.
  final ahora = DateTime(2026, 11, 11, 10);

  test('hora con a. m. / p. m. y las 12', () {
    expect(hora(DateTime(2026, 11, 11, 23, 59)), '11:59 p. m.');
    expect(hora(DateTime(2026, 11, 11, 7)), '7:00 a. m.');
    expect(hora(DateTime(2026, 11, 11, 0, 5)), '12:05 a. m.');
    expect(hora(DateTime(2026, 11, 11, 12)), '12:00 p. m.');
  });

  test('fechaCorta usa hoy, mañana, ayer, el día de la semana o la fecha', () {
    expect(fechaCorta(DateTime(2026, 11, 11, 23, 59), ahora), 'hoy 11:59 p. m.');
    expect(fechaCorta(DateTime(2026, 11, 12, 14), ahora), 'mañana 2:00 p. m.');
    expect(fechaCorta(DateTime(2026, 11, 10, 18), ahora), 'ayer 6:00 p. m.');
    expect(fechaCorta(DateTime(2026, 11, 13, 14), ahora), 'vie 2:00 p. m.');
    expect(fechaCorta(DateTime(2026, 11, 25, 14), ahora), '25/11 · 2:00 p. m.');
  });

  test('fechaLarga para el detalle', () {
    expect(fechaLarga(DateTime(2026, 11, 18, 23, 59), ahora), 'Mié 18/11 · 11:59 p. m.');
    expect(fechaLarga(DateTime(2026, 11, 11, 23, 59), ahora), 'Hoy · 11:59 p. m.');
  });

  test('rangoBloque junta el sufijo si es el mismo', () {
    expect(rangoBloque(DateTime(2026, 11, 15, 14), DateTime(2026, 11, 15, 16)), 'Dom 15 · 2:00 – 4:00 p. m.');
    expect(rangoBloque(DateTime(2026, 11, 17, 10), DateTime(2026, 11, 17, 12)), 'Mar 17 · 10:00 a. m. – 12:00 p. m.');
  });

  test('tiempoRestante', () {
    expect(tiempoRestante(actividad('a', fecha: DateTime(2026, 11, 11, 23)), ahora), 'Vence hoy');
    expect(tiempoRestante(actividad('a', fecha: DateTime(2026, 11, 12, 9)), ahora), 'Vence mañana');
    expect(tiempoRestante(actividad('a', fecha: DateTime(2026, 11, 14)), ahora), 'Faltan 3 días');
    expect(tiempoRestante(actividad('a', fecha: DateTime(2026, 11, 11, 8)), ahora), 'Vencida');
    final cerrada = actividad('a', fecha: DateTime(2026, 11, 14), estado: EstadoActividad.completada);
    expect(tiempoRestante(cerrada, ahora), isNull);
  });

  test('vencio', () {
    expect(vencio(DateTime(2026, 11, 11, 8), ahora), 'venció hoy');
    expect(vencio(DateTime(2026, 11, 10, 23, 59), ahora), 'venció ayer');
    expect(vencio(DateTime(2026, 11, 8), ahora), 'venció hace 3 días');
  });

  test('porcentaje y parte de la nota', () {
    expect(porcentajeTexto(15), '15 %');
    expect(porcentajeTexto(12.5), '12,5 %');
    expect(parteDeLaNota(actividad('a', fecha: ahora)), '10 %');
  });

  test('mensajeATiempo', () {
    final limite = DateTime(2026, 11, 13, 23, 59);
    expect(mensajeATiempo(limite, ahora), '2 días antes de la fecha límite.');
    expect(mensajeATiempo(limite, DateTime(2026, 11, 12, 9)), 'Un día antes de la fecha límite.');
    expect(mensajeATiempo(limite, DateTime(2026, 11, 13, 20)), 'Antes de la fecha límite.');
    expect(mensajeATiempo(limite, DateTime(2026, 11, 14)), isNull);
  });

  test('bloquesVisibles quita cancelados y descartados', () {
    final bloques = [
      bloque('b1', inicio: ahora),
      bloque('b2', inicio: ahora, estado: EstadoBloque.completado),
      bloque('b3', inicio: ahora, estado: EstadoBloque.cancelado),
      bloque('b4', inicio: ahora, estado: EstadoBloque.descartado),
    ];
    expect(bloquesVisibles(bloques).map((b) => b.id), ['b1', 'b2']);
  });
}
