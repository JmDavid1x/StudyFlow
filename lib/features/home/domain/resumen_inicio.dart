import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/tasks/domain/semana.dart';

/// Qué fechas hay que pedirle al repositorio para armar Inicio: desde ayer
/// (o el lunes, lo que sea antes) hasta el final de la semana o los próximos
/// 7 días (lo que sea después), para que "Próximas" no quede vacía el domingo.
class RangoInicio {
  RangoInicio(DateTime ahora)
    : desde = _min(inicioDeSemana(ahora), inicioDelDia(ahora).subtract(const Duration(days: 1))),
      hasta = _max(finDeSemana(ahora), _diasDespues(ahora, diasProximas + 1));

  /// Cuántos días hacia adelante se muestran en "Próximas".
  static const diasProximas = 7;

  final DateTime desde;
  final DateTime hasta;

  static DateTime _min(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
  static DateTime _max(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
}

DateTime _diasDespues(DateTime fecha, int dias) => DateTime(fecha.year, fecha.month, fecha.day + dias);

/// Todo lo que muestra la pestaña Inicio, ya calculado.
class ResumenInicio {
  const ResumenInicio({
    required this.entregasSemana,
    required this.proximoExamen,
    required this.horasPlaneadas,
    required this.completadasSemana,
    required this.totalSemana,
    required this.prioridadesHoy,
    required this.proximas,
    required this.bloquePendienteAyer,
    required this.notificacionesSinLeer,
  });

  /// Tareas y proyectos (no exámenes) con fecha de lunes a domingo.
  final int entregasSemana;

  /// El examen pendiente más cercano que todavía no pasa (nulo si no hay).
  final Actividad? proximoExamen;

  /// Σ (fin − inicio) de los bloques pendientes de la semana.
  final Duration horasPlaneadas;

  /// Progreso semanal: completadas (o presentados) ÷ actividades con fecha en la semana.
  final int completadasSemana;
  final int totalSemana;

  /// Sin cerrar que vencen hoy: prioridad alta primero y luego por hora.
  final List<Actividad> prioridadesHoy;

  /// Sin cerrar que vencen en los próximos [RangoInicio.diasProximas] días.
  final List<Actividad> proximas;

  /// Un bloque de ayer que quedó pendiente (el aviso de arriba en Inicio).
  final BloqueEstudio? bloquePendienteAyer;

  final int notificacionesSinLeer;

  double get progresoSemanal => totalSemana == 0 ? 0 : completadasSemana / totalSemana;

  bool get hayNovedades => notificacionesSinLeer > 0;

  /// Figma 11: todavía no hay nada que entregar.
  bool get sinActividades => totalSemana == 0 && prioridadesHoy.isEmpty && proximas.isEmpty;
}

/// Calcula Inicio a partir de lo que trae el repositorio. [ahora] llega por
/// parámetro para probarlo con fechas fijas.
ResumenInicio calcularResumenInicio({
  required List<Actividad> actividades,
  required List<BloqueEstudio> bloques,
  required List<Notificacion> notificaciones,
  required DateTime ahora,
}) {
  final lunes = inicioDeSemana(ahora);
  final finSemana = finDeSemana(ahora);
  final hoy = inicioDelDia(ahora);
  final manana = finDelDia(ahora);
  final ayer = hoy.subtract(const Duration(days: 1));
  final limiteProximas = _diasDespues(ahora, RangoInicio.diasProximas + 1);

  final deLaSemana = actividades.where((a) => estaEntre(a.fechaLimite, lunes, finSemana)).toList();
  final pendientes = actividades.where((a) => !a.estado.estaCerrada).toList();

  final examenes =
      pendientes
          .where((a) => a.esExamen && a.estado == EstadoActividad.pendiente && !a.fechaLimite.isBefore(ahora))
          .toList()
        ..sort((a, b) => a.fechaLimite.compareTo(b.fechaLimite));

  final horas = bloques
      .where((b) => b.estado == EstadoBloque.pendiente && estaEntre(b.inicio, lunes, finSemana))
      .fold(Duration.zero, (total, b) => total + b.duracion);

  final prioridadesHoy = pendientes.where((a) => estaEntre(a.fechaLimite, hoy, manana)).toList()
    ..sort((a, b) {
      final porPrioridad = b.prioridad.index.compareTo(a.prioridad.index);
      return porPrioridad != 0 ? porPrioridad : a.fechaLimite.compareTo(b.fechaLimite);
    });

  final proximas = pendientes.where((a) => estaEntre(a.fechaLimite, manana, limiteProximas)).toList()
    ..sort((a, b) => a.fechaLimite.compareTo(b.fechaLimite));

  final pendientesAyer =
      bloques.where((b) => b.estado == EstadoBloque.pendiente && estaEntre(b.inicio, ayer, hoy)).toList()
        ..sort((a, b) => b.inicio.compareTo(a.inicio));

  return ResumenInicio(
    entregasSemana: deLaSemana.where((a) => !a.esExamen).length,
    proximoExamen: examenes.isEmpty ? null : examenes.first,
    horasPlaneadas: horas,
    completadasSemana: deLaSemana
        .where((a) => a.estado == EstadoActividad.completada || a.estado == EstadoActividad.presentado)
        .length,
    totalSemana: deLaSemana.length,
    prioridadesHoy: prioridadesHoy,
    proximas: proximas,
    bloquePendienteAyer: pendientesAyer.isEmpty ? null : pendientesAyer.first,
    notificacionesSinLeer: notificaciones.where((n) => !n.leida && !n.programadaPara.isAfter(ahora)).length,
  );
}
