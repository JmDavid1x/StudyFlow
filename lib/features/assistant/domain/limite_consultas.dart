import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/data.dart';

/// Consultas a la IA que trae el plan gratis cada semana.
const consultasGratisPorSemana = 5;

/// Lunes a las 00:00 de la semana de [ahora]. Ahí se reinician las consultas.
DateTime inicioDeSemana(DateTime ahora) =>
    DateTime(ahora.year, ahora.month, ahora.day - (ahora.weekday - 1));

/// Consultas gastadas esta semana: respuestas de la IA (no de respaldo)
/// creadas desde el lunes. Ver [MensajeAsistente.cuentaComoConsulta].
int consultasUsadas(Iterable<MensajeAsistente> mensajes, DateTime ahora) {
  final lunes = inicioDeSemana(ahora);
  return mensajes
      .where((m) => m.cuentaComoConsulta && !m.creadoEn.isBefore(lunes))
      .length;
}

/// Cuánto le queda al usuario esta semana. Plus no tiene límite.
class LimiteConsultas extends Equatable {
  const LimiteConsultas({required this.usadas, required this.esPlus});

  final int usadas;
  final bool esPlus;

  int get restantes => esPlus
      ? consultasGratisPorSemana
      : (consultasGratisPorSemana - usadas).clamp(0, consultasGratisPorSemana);

  /// Si es false, la pregunta se responde con el orden de respaldo.
  bool get puedeConsultarIA => esPlus || usadas < consultasGratisPorSemana;

  /// De 0 a 1 para la barra de progreso.
  double get progreso =>
      esPlus ? 0 : (usadas / consultasGratisPorSemana).clamp(0, 1).toDouble();

  /// "3 de 5 gratis" o "Plus".
  String get etiqueta =>
      esPlus ? 'Plus' : '$usadas de $consultasGratisPorSemana gratis';

  @override
  List<Object?> get props => [usadas, esPlus];
}
