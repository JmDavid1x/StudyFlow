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
