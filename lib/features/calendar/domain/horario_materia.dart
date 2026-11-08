import 'package:studyflow/core/data/data.dart';

/// Un horario de clase junto con su materia (nombre y color), porque la
/// tabla horarios_clase solo trae el id de la materia.
class HorarioMateria {
  const HorarioMateria({required this.horario, required this.materia});

  final HorarioClase horario;
  final Materia materia;

  /// Saca todos los horarios de una lista de materias pedidas con Materia.select.
  static List<HorarioMateria> deMaterias(List<Materia> materias) => [
    for (final materia in materias)
      for (final horario in materia.horarios)
        HorarioMateria(horario: horario, materia: materia),
  ];

  /// ¿Hay clase este día? 1 = lunes … 7 = domingo, igual que DateTime.weekday.
  bool esElDia(DateTime dia) => horario.diaSemana == dia.weekday;

  DateTime inicioEn(DateTime dia) => horario.horaInicio.enDia(dia);
  DateTime finEn(DateTime dia) => horario.horaFin.enDia(dia);
}
