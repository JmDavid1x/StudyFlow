import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/calendar/domain/horario_materia.dart';

/// Una fila de la agenda de un día: clase, bloque de estudio o entrega
/// (tarea, proyecto o examen). Todas tienen la hora en que van en la lista.
sealed class EntradaAgenda {
  const EntradaAgenda();

  DateTime get inicio;

  /// Orden cuando dos cosas empiezan a la misma hora: clase, bloque, entrega.
  int get _orden;
}

class ClaseEnAgenda extends EntradaAgenda {
  const ClaseEnAgenda(this.clase, this.dia);

  final HorarioMateria clase;
  final DateTime dia;

  @override
  DateTime get inicio => clase.inicioEn(dia);
  DateTime get fin => clase.finEn(dia);

  @override
  int get _orden => 0;
}

class BloqueEnAgenda extends EntradaAgenda {
  const BloqueEnAgenda(this.bloque);

  final BloqueEstudio bloque;

  @override
  DateTime get inicio => bloque.inicio;

  @override
  int get _orden => 1;
}

class EntregaEnAgenda extends EntradaAgenda {
  const EntregaEnAgenda(this.actividad);

  final Actividad actividad;

  @override
  DateTime get inicio => actividad.fechaLimite;

  @override
  int get _orden => 2;
}

/// Lunes de la semana de [fecha], a las 00:00.
DateTime inicioDeSemana(DateTime fecha) => DateTime(
  fecha.year,
  fecha.month,
  fecha.day,
).subtract(Duration(days: fecha.weekday - 1));

bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Arma la agenda de [dia] ordenada por hora:
/// - clases: horarios cuyo día de la semana es el de [dia];
/// - entregas: actividades con fecha límite ese día;
/// - bloques: bloques que empiezan ese día y están pendientes o completados.
List<EntradaAgenda> agendaDelDia(
  DateTime dia, {
  required List<HorarioMateria> horarios,
  required List<Actividad> actividades,
  required List<BloqueEstudio> bloques,
}) {
  final entradas = <EntradaAgenda>[
    for (final h in horarios)
      if (h.esElDia(dia)) ClaseEnAgenda(h, dia),
    for (final b in bloques)
      if (mismoDia(b.inicio, dia) &&
          (b.estado == EstadoBloque.pendiente ||
              b.estado == EstadoBloque.completado))
        BloqueEnAgenda(b),
    for (final a in actividades)
      if (mismoDia(a.fechaLimite, dia)) EntregaEnAgenda(a),
  ];
  entradas.sort((x, y) {
    final porHora = x.inicio.compareTo(y.inicio);
    return porHora != 0 ? porHora : x._orden.compareTo(y._orden);
  });
  return entradas;
}

/// ¿El día lleva punto en la franja? Sí si tiene una actividad sin cerrar o
/// un bloque pendiente. Las clases no cuentan.
bool tienePendientes(
  DateTime dia, {
  required List<Actividad> actividades,
  required List<BloqueEstudio> bloques,
}) =>
    actividades.any(
      (a) => mismoDia(a.fechaLimite, dia) && !a.estado.estaCerrada,
    ) ||
    bloques.any(
      (b) => mismoDia(b.inicio, dia) && b.estado == EstadoBloque.pendiente,
    );
