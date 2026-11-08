import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/calendar/domain/horario_materia.dart';

/// Con qué se cruza un bloque nuevo o reprogramado.
class CruceBloque {
  const CruceBloque({
    required this.esClase,
    required this.nombre,
    required this.inicio,
    required this.fin,
  });

  /// true si es una clase; false si es otro bloque de estudio.
  final bool esClase;

  /// Materia de la clase o título de la actividad del otro bloque.
  final String nombre;
  final DateTime inicio;
  final DateTime fin;

  /// "Se cruza con tu clase de Cálculo Integral (9:00 a. m. – 11:00 a. m.)."
  String get mensaje {
    final rango = '${formatoHora(inicio)} – ${formatoHora(fin)}';
    return esClase
        ? 'Se cruza con tu clase de $nombre ($rango).'
        : 'Se cruza con tu bloque "$nombre" ($rango).';
  }
}

/// Busca el primer cruce de un bloque en [inicio, fin) con:
/// - las clases de cada día que toca el bloque;
/// - los otros bloques pendientes ([ignorar] deja por fuera el bloque que
///   se está reprogramando, para que no choque consigo mismo).
/// Devuelve null si el horario está libre.
CruceBloque? buscarCruce({
  required DateTime inicio,
  required DateTime fin,
  required List<HorarioMateria> horarios,
  required List<BloqueEstudio> bloques,
  String? ignorar,
}) {
  final ultimoDia = DateTime(fin.year, fin.month, fin.day);
  for (
    var dia = DateTime(inicio.year, inicio.month, inicio.day);
    !dia.isAfter(ultimoDia);
    dia = DateTime(dia.year, dia.month, dia.day + 1)
  ) {
    for (final clase in horarios) {
      if (!clase.esElDia(dia)) continue;
      final claseInicio = clase.inicioEn(dia);
      final claseFin = clase.finEn(dia);
      if (inicio.isBefore(claseFin) && claseInicio.isBefore(fin)) {
        return CruceBloque(
          esClase: true,
          nombre: clase.materia.nombre,
          inicio: claseInicio,
          fin: claseFin,
        );
      }
    }
  }

  for (final otro in bloques) {
    if (otro.id == ignorar || otro.estado != EstadoBloque.pendiente) continue;
    if (otro.seCruzaCon(inicio, fin)) {
      return CruceBloque(
        esClase: false,
        nombre: otro.actividadTitulo ?? 'otro bloque',
        inicio: otro.inicio,
        fin: otro.fin,
      );
    }
  }
  return null;
}

/// Revisa un bloque antes de guardarlo. Devuelve el mensaje de error para
/// mostrar, o null si se puede guardar.
String? validarBloque({
  required DateTime inicio,
  required DateTime fin,
  required List<HorarioMateria> horarios,
  required List<BloqueEstudio> bloques,
  String? ignorar,
}) {
  if (!fin.isAfter(inicio)) {
    return 'La hora de fin debe ser después de la de inicio.';
  }
  return buscarCruce(
    inicio: inicio,
    fin: fin,
    horarios: horarios,
    bloques: bloques,
    ignorar: ignorar,
  )?.mensaje;
}

/// "9:00 a. m.", igual que sfFormatTime del design system, pero sin Flutter
/// para que la regla se pueda probar en Dart puro.
String formatoHora(DateTime t) {
  final hora = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minuto = t.minute.toString().padLeft(2, '0');
  return '$hora:$minuto ${t.hour < 12 ? 'a. m.' : 'p. m.'}';
}
