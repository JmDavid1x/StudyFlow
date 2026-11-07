import 'package:equatable/equatable.dart';

/// Una hora del día sin fecha, para las columnas `time` de la base
/// (horarios de clase y horas de los avisos). Llega como '07:00:00'.
class Hora extends Equatable implements Comparable<Hora> {
  const Hora(this.hora, this.minuto)
      : assert(hora >= 0 && hora < 24),
        assert(minuto >= 0 && minuto < 60);

  factory Hora.fromDb(String value) {
    final partes = value.split(':');
    return Hora(int.parse(partes[0]), int.parse(partes[1]));
  }

  final int hora;
  final int minuto;

  /// Para guardar en la base: '07:00'.
  String toDb() => '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';

  int get enMinutos => hora * 60 + minuto;

  /// Esta hora en un día concreto.
  DateTime enDia(DateTime dia) => DateTime(dia.year, dia.month, dia.day, hora, minuto);

  @override
  int compareTo(Hora other) => enMinutos.compareTo(other.enMinutos);

  @override
  List<Object?> get props => [hora, minuto];
}
