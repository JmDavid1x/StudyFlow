import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/assistant/domain/orden_respaldo.dart';
import 'package:studyflow/features/assistant/domain/programar_bloques.dart';

/// La IA todavía no está conectada (llega en el Sprint 3). El caso de uso la
/// atrapa y responde con el orden de respaldo.
class IaNoDisponible implements Exception {
  const IaNoDisponible();
}

/// Qué datos necesita el asistente (Figma 24, 31 y S4). La implementación
/// con Supabase está en data/assistant_repository_impl.dart.
abstract class AssistantRepository {
  /// La conversación guardada, del mensaje más viejo al más nuevo.
  Future<List<MensajeAsistente>> historial();

  /// Guarda un mensaje (del usuario o del asistente) y lo devuelve con su id.
  Future<MensajeAsistente> enviarMensaje({
    required RolMensaje rol,
    required String contenido,
    bool usadoRespaldo = false,
  });

  /// Respuesta de la IA a [pregunta]. En el Sprint 2 lanza [IaNoDisponible].
  Future<String> responderConIA(String pregunta, List<Actividad> pendientes);

  /// Actividades del periodo activo que no están cerradas, por fecha límite.
  Future<List<Actividad>> actividadesPendientes();

  /// Horarios de clase de las materias del periodo activo.
  Future<List<HorarioClase>> horariosDeClase();

  /// Bloques pendientes que terminan después de [desde].
  Future<List<BloqueEstudio>> bloquesPendientesDesde(DateTime desde);

  /// El plan activo (con sus actividades), o null si no hay.
  Future<PlanEstudio?> planActivo();

  /// Reemplaza el plan activo:
  /// 1. desactiva el anterior y cancela sus bloques pendientes;
  /// 2. crea el plan (tipo solicitado);
  /// 3. agrega sus actividades en orden (1, 2, 3…);
  /// 4. crea los bloques con plan_id y actividad_id.
  Future<PlanEstudio> crearPlan({
    required String resumen,
    required bool usadoRespaldo,
    required List<ItemOrden> orden,
    required List<BloquePlaneado> bloques,
    String? mensajeId,
  });
}
