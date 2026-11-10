import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/data.dart';

/// Lo que pasa en la pestaña Calendario (Figma 20).
sealed class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

/// Se abre la pestaña: carga la semana de hoy.
final class CalendarioIniciado extends CalendarEvent {
  const CalendarioIniciado();
}

/// Se toca un día de la franja.
final class DiaElegido extends CalendarEvent {
  const DiaElegido(this.dia);

  final DateTime dia;

  @override
  List<Object?> get props => [dia];
}

/// Flechas del mes: una semana atrás (-1) o adelante (1).
final class SemanaCambiada extends CalendarEvent {
  const SemanaCambiada(this.semanas);

  final int semanas;

  @override
  List<Object?> get props => [semanas];
}

/// Volver a pedir la semana (al volver de otra pantalla o en "Reintentar").
final class CalendarioRecargado extends CalendarEvent {
  const CalendarioRecargado();
}

/// Circulito de un bloque: completarlo sin salir del calendario.
final class BloqueCompletado extends CalendarEvent {
  const BloqueCompletado(this.bloque);

  final BloqueEstudio bloque;

  @override
  List<Object?> get props => [bloque];
}
