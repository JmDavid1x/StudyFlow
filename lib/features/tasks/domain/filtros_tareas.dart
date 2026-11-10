import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/tasks/domain/semana.dart';

/// Los chips de la pestaña Tareas.
enum FiltroTareas { todas, vencidas, hoy, semana, completadas }

/// Actividades repartidas en las secciones de la pestaña Tareas. Cada
/// actividad queda en una sola sección.
class TareasAgrupadas {
  const TareasAgrupadas({
    required this.vencidas,
    required this.hoy,
    required this.semana,
    required this.masAdelante,
    required this.completadas,
  });

  /// Pasó la fecha y no está cerrada. La más antigua primero.
  final List<Actividad> vencidas;

  /// Vencen hoy y todavía no pasa la hora.
  final List<Actividad> hoy;

  /// Vencen después de hoy y antes del lunes siguiente.
  final List<Actividad> semana;

  /// Pendientes de las semanas siguientes (solo se ven en "Todas").
  final List<Actividad> masAdelante;

  /// Cerradas: completadas, presentados y no entregadas. La más reciente primero.
  final List<Actividad> completadas;

  /// Lo que se ve con cada chip.
  List<Actividad> de(FiltroTareas filtro) => switch (filtro) {
    FiltroTareas.todas => [...vencidas, ...hoy, ...semana, ...masAdelante, ...completadas],
    FiltroTareas.vencidas => vencidas,
    FiltroTareas.hoy => hoy,
    FiltroTareas.semana => semana,
    FiltroTareas.completadas => completadas,
  };

  bool get estaVacia => vencidas.isEmpty && hoy.isEmpty && semana.isEmpty && masAdelante.isEmpty && completadas.isEmpty;
}

/// Reparte [actividades] según [ahora] (se recibe por parámetro para poder
/// probarlo con fechas fijas).
TareasAgrupadas agruparTareas(List<Actividad> actividades, DateTime ahora) {
  final vencidas = <Actividad>[];
  final hoy = <Actividad>[];
  final semana = <Actividad>[];
  final masAdelante = <Actividad>[];
  final completadas = <Actividad>[];

  final finHoy = finDelDia(ahora);
  final finSemana = finDeSemana(ahora);

  for (final actividad in actividades) {
    if (actividad.estado.estaCerrada) {
      completadas.add(actividad);
    } else if (esVencida(actividad, ahora)) {
      vencidas.add(actividad);
    } else if (actividad.fechaLimite.isBefore(finHoy)) {
      hoy.add(actividad);
    } else if (actividad.fechaLimite.isBefore(finSemana)) {
      semana.add(actividad);
    } else {
      masAdelante.add(actividad);
    }
  }

  int porFecha(Actividad a, Actividad b) => a.fechaLimite.compareTo(b.fechaLimite);
  DateTime cierre(Actividad a) => a.completadaEn ?? a.fechaLimite;

  return TareasAgrupadas(
    vencidas: vencidas..sort(porFecha),
    hoy: hoy..sort(porFecha),
    semana: semana..sort(porFecha),
    masAdelante: masAdelante..sort(porFecha),
    completadas: completadas..sort((a, b) => cierre(b).compareTo(cierre(a))),
  );
}

/// Vencida = pasó la fecha y no está cerrada. También cuenta si la base ya
/// la guardó con estado `vencida`.
bool esVencida(Actividad actividad, DateTime ahora) =>
    !actividad.estado.estaCerrada && (actividad.estado == EstadoActividad.vencida || actividad.estaVencida(ahora));
