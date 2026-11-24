import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/features/assistant/domain/formato_respuesta.dart';

void main() {
  group('lineasDeRespuesta', () {
    test('separa párrafo y lista numerada de la IA', () {
      final lineas = lineasDeRespuesta(
        'Te sugiero este orden:\n'
        '1. **Taller 3**: vence hoy a las 11:59 p. m.\n'
        '2) Lectura capítulo 4\n'
        '\n'
        'Ánimo, tú puedes.',
      );

      expect(lineas, const [
        LineaRespuesta(TipoLinea.parrafo, 'Te sugiero este orden:'),
        LineaRespuesta(
          TipoLinea.numerada,
          '**Taller 3**: vence hoy a las 11:59 p. m.',
          numero: 1,
        ),
        LineaRespuesta(TipoLinea.numerada, 'Lectura capítulo 4', numero: 2),
        LineaRespuesta(TipoLinea.parrafo, 'Ánimo, tú puedes.'),
      ]);
    });

    test('reconoce viñetas con guion, asterisco o punto', () {
      final lineas = lineasDeRespuesta('- uno\n* dos\n• tres');
      expect(lineas.map((l) => l.tipo), everyElement(TipoLinea.vineta));
      expect(lineas.map((l) => l.texto), ['uno', 'dos', 'tres']);
    });

    test('el orden de respaldo guardado también sale como lista', () {
      final lineas = lineasDeRespuesta(
        'No pude responderte con la IA, así que te dejo el orden de respaldo.\n'
        '1. Taller 3: Vence hoy a las 11:59 p. m.',
      );
      expect(lineas.last.tipo, TipoLinea.numerada);
      expect(lineas.last.numero, 1);
    });

    test('un año o una hora al inicio no se vuelve lista', () {
      expect(
        lineasDeRespuesta('2026 va a ser buen año').single.tipo,
        TipoLinea.parrafo,
      );
    });
  });

  group('trozosConNegrita', () {
    test('marca lo que va entre dobles asteriscos', () {
      expect(trozosConNegrita('Empieza por **Taller 3** hoy'), [
        ('Empieza por ', false),
        ('Taller 3', true),
        (' hoy', false),
      ]);
    });

    test('sin cerrar se deja el texto tal cual', () {
      expect(trozosConNegrita('Ojo con **esto'), [('Ojo con **esto', false)]);
    });
  });
}
