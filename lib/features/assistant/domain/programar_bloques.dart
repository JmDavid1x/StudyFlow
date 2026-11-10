import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/assistant/domain/orden_respaldo.dart';

/// Un bloque que el asistente propone para una actividad del plan.
class BloquePlaneado extends Equatable {
  const BloquePlaneado({
    required this.actividadId,
    required this.inicio,
    required this.fin,
  });

  final String actividadId;
  final DateTime inicio;
  final DateTime fin;

  @override
  List<Object?> get props => [actividadId, inicio, fin];
}

/// Franja del día en que el asistente pone bloques: de 8:00 a. m. a 9:00 p. m.
const horaInicioEstudio = 8;
const horaFinEstudio = 21;

/// Cada cuánto se prueba un horario (los bloques empiezan en :00 o :30).
const _paso = Duration(minutes: 30);

/// Hasta cuántos días adelante se busca espacio.
const _diasMaximos = 14;

/// Reparte las horas sugeridas de cada actividad, en el orden del plan, en el
/// primer espacio libre desde [ahora]:
/// - dentro de la franja de estudio de cada día;
/// - sin cruzarse con las clases ([horarios]) ni con [ocupados] (los bloques
///   pendientes que ya tiene el usuario) ni con los que se van poniendo;
/// - terminando antes de la fecha límite de la actividad.
/// Si una actividad no cabe antes de su fecha límite, se queda sin bloque
/// (sigue en el plan, pero no se agenda).
List<BloquePlaneado> programarBloques({
  required List<ItemOrden> orden,
  required List<HorarioClase> horarios,
  required List<BloqueEstudio> ocupados,
  required DateTime ahora,
}) {
  final tomados = <(DateTime, DateTime)>[
    for (final bloque in ocupados)
      if (bloque.estado == EstadoBloque.pendiente) (bloque.inicio, bloque.fin),
  ];
  final desde = _siguientePaso(ahora);
  final resultado = <BloquePlaneado>[];

  for (final item in orden) {
    final duracion = Duration(minutes: (item.horasSugeridas * 60).round());
    final hueco = _primerHueco(
      desde: desde,
      duracion: duracion,
      limite: item.actividad.fechaLimite,
      horarios: horarios,
      tomados: tomados,
    );
    if (hueco == null) continue;
    tomados.add(hueco);
    resultado.add(
      BloquePlaneado(
        actividadId: item.actividad.id,
        inicio: hueco.$1,
        fin: hueco.$2,
      ),
    );
  }
  return resultado;
}

(DateTime, DateTime)? _primerHueco({
  required DateTime desde,
  required Duration duracion,
  required DateTime limite,
  required List<HorarioClase> horarios,
  required List<(DateTime, DateTime)> tomados,
}) {
  for (var dia = 0; dia < _diasMaximos; dia++) {
    final base = DateTime(desde.year, desde.month, desde.day + dia);
    final aperturaDia = DateTime(
      base.year,
      base.month,
      base.day,
      horaInicioEstudio,
    );
    final cierreDia = DateTime(base.year, base.month, base.day, horaFinEstudio);
    var inicio = aperturaDia.isBefore(desde) ? desde : aperturaDia;
    while (true) {
      final fin = inicio.add(duracion);
      if (fin.isAfter(cierreDia) || fin.isAfter(limite)) break;
      final choca =
          _chocaConClase(inicio, fin, horarios) ||
          tomados.any((t) => inicio.isBefore(t.$2) && t.$1.isBefore(fin));
      if (!choca) return (inicio, fin);
      inicio = inicio.add(_paso);
    }
    if (!aperturaDia.isBefore(limite)) return null;
  }
  return null;
}

bool _chocaConClase(
  DateTime inicio,
  DateTime fin,
  List<HorarioClase> horarios,
) {
  for (final clase in horarios) {
    if (clase.diaSemana != inicio.weekday) continue;
    final claseInicio = clase.horaInicio.enDia(inicio);
    final claseFin = clase.horaFin.enDia(inicio);
    if (inicio.isBefore(claseFin) && claseInicio.isBefore(fin)) return true;
  }
  return false;
}

/// La siguiente hora en punto o y media después de [t].
DateTime _siguientePaso(DateTime t) {
  final base = DateTime(t.year, t.month, t.day, t.hour);
  final media = base.add(_paso);
  if (!t.isAfter(base)) return base;
  if (!t.isAfter(media)) return media;
  return base.add(const Duration(hours: 1));
}
