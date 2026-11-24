import 'package:equatable/equatable.dart';

/// Qué es cada línea de una respuesta del asistente.
enum TipoLinea { parrafo, numerada, vineta }

/// Una línea de la respuesta ya sin sus marcas ("1. ", "- ", "* ").
class LineaRespuesta extends Equatable {
  const LineaRespuesta(this.tipo, this.texto, {this.numero});

  final TipoLinea tipo;
  final String texto;

  /// Solo en las numeradas: 1, 2, 3…
  final int? numero;

  @override
  List<Object?> get props => [tipo, texto, numero];
}

final _numerada = RegExp(r'^(\d{1,2})[.)]\s+(.+)$');
final _vineta = RegExp(r'^[-*•]\s+(.+)$');

/// Separa la respuesta de la IA (o el orden de respaldo guardado) en líneas
/// para mostrarla con formato: párrafos, lista numerada y viñetas. Las líneas
/// vacías se saltan. Dart puro, para probarlo con tests.
List<LineaRespuesta> lineasDeRespuesta(String texto) {
  final lineas = <LineaRespuesta>[];
  for (final cruda in texto.split('\n')) {
    final linea = cruda.trim();
    if (linea.isEmpty) continue;
    final numerada = _numerada.firstMatch(linea);
    if (numerada != null) {
      lineas.add(
        LineaRespuesta(
          TipoLinea.numerada,
          numerada.group(2)!.trim(),
          numero: int.parse(numerada.group(1)!),
        ),
      );
      continue;
    }
    final vineta = _vineta.firstMatch(linea);
    if (vineta != null) {
      lineas.add(LineaRespuesta(TipoLinea.vineta, vineta.group(1)!.trim()));
      continue;
    }
    lineas.add(LineaRespuesta(TipoLinea.parrafo, linea));
  }
  return lineas;
}

/// Parte un texto con **negrita** (Markdown) en trozos (texto, esNegrita).
/// Si una marca queda sin cerrar, se muestra tal cual.
List<(String, bool)> trozosConNegrita(String texto) {
  final partes = texto.split('**');
  if (partes.length.isEven) return [(texto, false)];
  return [
    for (final (indice, parte) in partes.indexed)
      if (parte.isNotEmpty) (parte, indice.isOdd),
  ];
}
