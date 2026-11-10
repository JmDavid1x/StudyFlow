import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/assistant/domain/limite_consultas.dart';

import 'fixtures.dart';

void main() {
  // Martes 10 de noviembre de 2026: la semana empezó el lunes 9.
  final ahora = DateTime(2026, 11, 10, 10);

  test('la semana empieza el lunes a medianoche', () {
    expect(inicioDeSemana(ahora), DateTime(2026, 11, 9));
    expect(inicioDeSemana(DateTime(2026, 11, 9, 0, 1)), DateTime(2026, 11, 9));
    expect(inicioDeSemana(DateTime(2026, 11, 15, 23)), DateTime(2026, 11, 9));
  });

  test('solo cuentan las respuestas de la IA desde el lunes', () {
    final mensajes = [
      mensaje('ia-lunes', creadoEn: DateTime(2026, 11, 9, 8)),
      mensaje('ia-hoy', creadoEn: DateTime(2026, 11, 10, 9)),
      mensaje(
        'respaldo',
        creadoEn: DateTime(2026, 11, 10, 9),
        usadoRespaldo: true,
      ),
      mensaje(
        'pregunta',
        creadoEn: DateTime(2026, 11, 10, 9),
        rol: RolMensaje.usuario,
      ),
      mensaje('domingo', creadoEn: DateTime(2026, 11, 8, 22)),
    ];

    expect(consultasUsadas(mensajes, ahora), 2);
  });

  group('LimiteConsultas', () {
    test('gratis con consultas disponibles', () {
      const limite = LimiteConsultas(usadas: 3, esPlus: false);
      expect(limite.puedeConsultarIA, isTrue);
      expect(limite.restantes, 2);
      expect(limite.etiqueta, '3 de 5 gratis');
      expect(limite.progreso, closeTo(0.6, 0.001));
    });

    test('gratis sin consultas: se responde con el respaldo', () {
      const limite = LimiteConsultas(usadas: 5, esPlus: false);
      expect(limite.puedeConsultarIA, isFalse);
      expect(limite.restantes, 0);
    });

    test('Plus no tiene límite', () {
      const limite = LimiteConsultas(usadas: 12, esPlus: true);
      expect(limite.puedeConsultarIA, isTrue);
      expect(limite.etiqueta, 'Plus');
    });
  });
}
