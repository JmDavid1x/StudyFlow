import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/assistant/domain/assistant_repository.dart';
import 'package:studyflow/features/assistant/domain/limite_consultas.dart';
import 'package:studyflow/features/assistant/domain/orden_respaldo.dart';

/// Lo que devuelve el asistente al enviar una pregunta.
class RespuestaAsistente {
  const RespuestaAsistente({
    required this.pregunta,
    required this.respuesta,
    required this.orden,
  });

  /// El mensaje del usuario, ya guardado.
  final MensajeAsistente pregunta;

  /// La respuesta, ya guardada. Si `usadoRespaldo`, no gastó consulta.
  final MensajeAsistente respuesta;

  /// El orden sugerido (para la tarjeta y para "Agregar al plan").
  final List<ItemOrden> orden;
}

/// Guarda la pregunta y la responde:
/// - si le quedan consultas (o es Plus), intenta con la IA;
/// - si la IA no responde o no le quedan consultas, responde con el orden de
///   respaldo, que no gasta consulta (usado_respaldo = true).
class EnviarPregunta {
  const EnviarPregunta(this._repositorio, {DateTime Function()? reloj})
    : _reloj = reloj ?? DateTime.now;

  final AssistantRepository _repositorio;
  final DateTime Function() _reloj;

  Future<RespuestaAsistente> call(String texto, LimiteConsultas limite) async {
    final pregunta = await _repositorio.enviarMensaje(
      rol: RolMensaje.usuario,
      contenido: texto.trim(),
    );
    final pendientes = await _repositorio.actividadesPendientes();
    final orden = ordenDeRespaldo(pendientes, _reloj());

    if (limite.puedeConsultarIA) {
      try {
        final texto = await _repositorio.responderConIA(
          pregunta.contenido,
          pendientes,
        );
        final respuesta = await _repositorio.enviarMensaje(
          rol: RolMensaje.asistente,
          contenido: texto,
        );
        return RespuestaAsistente(
          pregunta: pregunta,
          respuesta: respuesta,
          orden: orden,
        );
      } catch (_) {
        // La IA no respondió: sigue con el respaldo.
      }
    }

    final respuesta = await _repositorio.enviarMensaje(
      rol: RolMensaje.asistente,
      contenido: respuestaDeRespaldo(
        orden,
        sinConsultas: !limite.puedeConsultarIA,
      ),
      usadoRespaldo: true,
    );
    return RespuestaAsistente(
      pregunta: pregunta,
      respuesta: respuesta,
      orden: orden,
    );
  }

  /// "Reintentar" (Figma 31): vuelve a pedirle a la IA la última pregunta.
  /// Si responde, guarda su respuesta; si no, lanza [IaNoDisponible] y no
  /// guarda nada (el orden de respaldo ya está en pantalla).
  Future<MensajeAsistente> reintentar(String pregunta) async {
    final pendientes = await _repositorio.actividadesPendientes();
    final texto = await _repositorio.responderConIA(pregunta, pendientes);
    return _repositorio.enviarMensaje(
      rol: RolMensaje.asistente,
      contenido: texto,
    );
  }
}
