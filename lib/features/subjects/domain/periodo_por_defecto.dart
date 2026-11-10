import 'package:equatable/equatable.dart';

/// Datos del semestre que se crea automáticamente si el usuario aún no tiene
/// un periodo activo.
class PeriodoPorDefecto extends Equatable {
  const PeriodoPorDefecto({
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
  });

  /// '2026-2'
  final String nombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  @override
  List<Object?> get props => [nombre, fechaInicio, fechaFin];
}

/// Semestre al que pertenece [hoy]: de julio en adelante es el `-2`
/// (3 de agosto al 5 de diciembre); antes, el `-1` (19 de enero al 30 de mayo).
PeriodoPorDefecto periodoPorDefecto(DateTime hoy) {
  final segundo = hoy.month >= 7;
  return segundo
      ? PeriodoPorDefecto(
          nombre: '${hoy.year}-2',
          fechaInicio: DateTime(hoy.year, 8, 3),
          fechaFin: DateTime(hoy.year, 12, 5),
        )
      : PeriodoPorDefecto(
          nombre: '${hoy.year}-1',
          fechaInicio: DateTime(hoy.year, 1, 19),
          fechaFin: DateTime(hoy.year, 5, 30),
        );
}
