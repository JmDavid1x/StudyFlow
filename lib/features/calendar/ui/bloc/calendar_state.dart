import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/calendar/domain/agenda_del_dia.dart';
import 'package:studyflow/features/calendar/domain/horario_materia.dart';

enum CalendarStatus { cargando, listo, error }

/// Estado de la pestaña Calendario: la semana que se ve, el día elegido y
/// lo que hay en esa semana (clases, entregas y bloques).
class CalendarState extends Equatable {
  const CalendarState({
    required this.dia,
    this.status = CalendarStatus.cargando,
    this.horarios = const [],
    this.actividades = const [],
    this.bloques = const [],
    this.error,
    this.errorAccion,
    this.completado,
  });

  final CalendarStatus status;

  /// Día elegido (00:00). La semana es la de este día.
  final DateTime dia;
  final List<HorarioMateria> horarios;

  /// Entregas y exámenes de la semana.
  final List<Actividad> actividades;

  /// Bloques pendientes o completados de la semana.
  final List<BloqueEstudio> bloques;

  /// Por qué no cargó la semana (status = error).
  final String? error;

  /// Por qué falló completar un bloque (se avisa sin perder la agenda).
  final String? errorAccion;

  /// Bloque recién completado: la pantalla abre la hoja S5 cuando llega.
  final BloqueEstudio? completado;

  DateTime get semana => inicioDeSemana(dia);

  /// La agenda del día elegido, ordenada por hora.
  List<EntradaAgenda> get agenda => agendaDelDia(
    dia,
    horarios: horarios,
    actividades: actividades,
    bloques: bloques,
  );

  /// ¿El día lleva punto en la franja?
  bool tienePunto(DateTime d) =>
      tienePendientes(d, actividades: actividades, bloques: bloques);

  /// Cuántas cosas pendientes tiene el día elegido ("4 pendientes").
  int get pendientes => agenda.where((e) {
    return switch (e) {
      ClaseEnAgenda() => false,
      BloqueEnAgenda(:final bloque) => bloque.estado == EstadoBloque.pendiente,
      EntregaEnAgenda(:final actividad) => !actividad.estado.estaCerrada,
    };
  }).length;

  CalendarState copyWith({
    CalendarStatus? status,
    DateTime? dia,
    List<HorarioMateria>? horarios,
    List<Actividad>? actividades,
    List<BloqueEstudio>? bloques,
    String? error,
    String? errorAccion,
    BloqueEstudio? completado,
  }) => CalendarState(
    status: status ?? this.status,
    dia: dia ?? this.dia,
    horarios: horarios ?? this.horarios,
    actividades: actividades ?? this.actividades,
    bloques: bloques ?? this.bloques,
    error: error,
    errorAccion: errorAccion,
    completado: completado,
  );

  @override
  List<Object?> get props => [
    status,
    dia,
    horarios,
    actividades,
    bloques,
    error,
    errorAccion,
    completado,
  ];
}
