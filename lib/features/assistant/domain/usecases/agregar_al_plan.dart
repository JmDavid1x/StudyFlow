import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/assistant/domain/assistant_repository.dart';
import 'package:studyflow/features/assistant/domain/orden_respaldo.dart';
import 'package:studyflow/features/assistant/domain/programar_bloques.dart';

/// El plan ya guardado y los bloques que se agendaron (para la hoja S4).
class PlanAgregado {
  const PlanAgregado({
    required this.plan,
    required this.orden,
    required this.bloques,
  });

  final PlanEstudio plan;
  final List<ItemOrden> orden;
  final List<BloquePlaneado> bloques;
}

/// "Agregar al plan": convierte el orden sugerido en el plan activo y agenda
/// sus bloques sin cruzarse con clases ni con otros bloques pendientes.
class AgregarAlPlan {
  const AgregarAlPlan(this._repositorio, {DateTime Function()? reloj})
    : _reloj = reloj ?? DateTime.now;

  final AssistantRepository _repositorio;
  final DateTime Function() _reloj;

  Future<PlanAgregado> call(
    List<ItemOrden> orden, {
    required bool usadoRespaldo,
    String? mensajeId,
  }) async {
    if (orden.isEmpty) {
      throw const AppException(
        'No hay actividades pendientes para agregar al plan.',
      );
    }
    final ahora = _reloj();
    final anterior = await _repositorio.planActivo();
    final horarios = await _repositorio.horariosDeClase();
    // Los bloques del plan anterior se van a cancelar: no ocupan espacio.
    final ocupados = (await _repositorio.bloquesPendientesDesde(
      ahora,
    )).where((b) => anterior == null || b.planId != anterior.id).toList();

    final bloques = programarBloques(
      orden: orden,
      horarios: horarios,
      ocupados: ocupados,
      ahora: ahora,
    );
    final plan = await _repositorio.crearPlan(
      resumen: resumenDelPlan(orden),
      usadoRespaldo: usadoRespaldo,
      orden: orden,
      bloques: bloques,
      mensajeId: mensajeId,
    );
    return PlanAgregado(plan: plan, orden: orden, bloques: bloques);
  }
}
