import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';

/// Cuánto le queda sin asignar a un componente de nota: su porcentaje menos
/// lo que ya valen sus actividades. [sinContar] deja por fuera la actividad
/// que se está editando, para no restarla dos veces.
///
/// Ejemplo: Proyecto vale 40 % y ya hay una entrega de 15 % → quedan 25 %.
double porcentajeRestante(
  ComponenteNota componente,
  List<PorcentajeAsignado> asignados, {
  String? sinContar,
}) {
  final usado = asignados
      .where(
        (a) => a.componenteId == componente.id && a.actividadId != sinContar,
      )
      .fold<double>(0, (suma, a) => suma + a.porcentaje);
  final restante = componente.porcentaje - usado;
  return restante < 0 ? 0 : restante;
}

/// Lee lo que el usuario escribe en "Valor en la nota". Acepta coma o punto y
/// hasta dos decimales ("12,5", "12.5", "15"). Si no es un número así,
/// devuelve null para que el formulario muestre el error.
double? leerPorcentaje(String texto) {
  final limpio = texto.replaceAll('%', '').trim();
  if (!RegExp(r'^\d{1,3}([.,]\d{1,2})?$').hasMatch(limpio)) return null;
  return double.parse(limpio.replaceAll(',', '.'));
}

/// Muestra un porcentaje como se escribe en Colombia, sin redondearlo a
/// entero: 12.5 → "12,5", 15.0 → "15", 33.25 → "33,25".
String textoPorcentaje(double valor) {
  final fijo = ((valor * 100).round() / 100).toStringAsFixed(2);
  return fijo.replaceFirst(RegExp(r'\.?0+$'), '').replaceAll('.', ',');
}
