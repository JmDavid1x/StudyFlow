import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/home/domain/textos_inicio.dart';

import '../tasks/fixtures.dart';

void main() {
  // Miércoles 11 nov 2026, 10:00 a. m.
  final ahora = DateTime(2026, 11, 11, 10);

  test('fechaDeHoy', () {
    expect(fechaDeHoy(ahora), 'Miércoles, 11 de noviembre');
    expect(fechaDeHoy(DateTime(2026, 11, 9)), 'Lunes, 9 de noviembre');
  });

  test('horasTexto', () {
    expect(horasTexto(Duration.zero), '0 h');
    expect(horasTexto(const Duration(minutes: 45)), '45 min');
    expect(horasTexto(const Duration(hours: 6)), '6 h');
    expect(horasTexto(const Duration(minutes: 90)), '1,5 h');
  });

  test('tarjetaExamen', () {
    expect(tarjetaExamen(null, ahora), ('–', 'sin parciales'));
    final jueves = actividad('e', fecha: DateTime(2026, 11, 12, 14), tipo: TipoActividad.examen);
    expect(tarjetaExamen(jueves, ahora), ('Mañana', 'Actividad e'));
    final viernes = actividad('e', fecha: DateTime(2026, 11, 13, 14), tipo: TipoActividad.examen);
    expect(tarjetaExamen(viernes, ahora).$1, 'Vie');
    final lejos = actividad('e', fecha: DateTime(2026, 11, 24, 14), tipo: TipoActividad.examen);
    expect(tarjetaExamen(lejos, ahora).$1, '24/11');
  });

  test('grupoDelDia', () {
    expect(grupoDelDia(DateTime(2026, 11, 11, 7), ahora), 'Hoy');
    expect(grupoDelDia(DateTime(2026, 11, 10, 18), ahora), 'Ayer');
    expect(grupoDelDia(DateTime(2026, 11, 4, 9), ahora), 'Mié 4/11');
  });
}
