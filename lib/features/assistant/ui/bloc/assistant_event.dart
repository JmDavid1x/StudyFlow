part of 'assistant_bloc.dart';

/// Lo que la pantalla del asistente le pide al [AssistantBloc].
sealed class AssistantEvent extends Equatable {
  const AssistantEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar (o recargar al volver de Plus) la conversación y el plan actual.
final class AsistenteIniciado extends AssistantEvent {
  const AsistenteIniciado();
}

/// Se envió una pregunta (escrita o tocando una sugerencia).
final class PreguntaEnviada extends AssistantEvent {
  const PreguntaEnviada(this.texto);

  final String texto;

  @override
  List<Object?> get props => [texto];
}

/// "Reintentar" en el aviso de sin conexión (Figma 31).
final class ReintentoPedido extends AssistantEvent {
  const ReintentoPedido();
}

/// "Agregar plan al calendario" o "Agregar este orden al calendario".
final class PlanPedido extends AssistantEvent {
  const PlanPedido();
}
