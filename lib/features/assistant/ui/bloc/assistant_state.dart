part of 'assistant_bloc.dart';

/// En qué va la carga del chat.
enum EstadoAsistente { cargando, listo, error }

class AssistantState extends Equatable {
  const AssistantState({
    this.estado = EstadoAsistente.cargando,
    this.mensajes = const [],
    this.limite = const LimiteConsultas(usadas: 0, esPlus: false),
    this.orden,
    this.respuestaId,
    this.enviando = false,
    this.agregando = false,
    this.planAgregado,
    this.planId = 0,
    this.mensaje,
    this.aviso,
    this.avisoId = 0,
  });

  final EstadoAsistente estado;

  /// La conversación, del más viejo al más nuevo.
  final List<MensajeAsistente> mensajes;

  /// "3 de 5 gratis" o Plus.
  final LimiteConsultas limite;

  /// El orden sugerido de la última respuesta (tarjeta y "Agregar al plan").
  final List<ItemOrden>? orden;

  /// Id del mensaje del asistente que lleva ese orden debajo.
  final String? respuestaId;

  /// Esperando la respuesta (se desactiva enviar).
  final bool enviando;

  /// Creando el plan y sus bloques.
  final bool agregando;

  /// El último plan creado, para la hoja S4. [planId] cambia cada vez.
  final PlanAgregado? planAgregado;
  final int planId;

  /// Error de la carga (estado error).
  final String? mensaje;

  /// Error de una acción, para un SnackBar. [avisoId] cambia cada vez.
  final String? aviso;
  final int avisoId;

  /// La respuesta que lleva el orden, si sigue en pantalla.
  MensajeAsistente? get respuestaConOrden {
    for (final m in mensajes.reversed) {
      if (m.id == respuestaId) return m;
    }
    return null;
  }

  /// La última pregunta del usuario (para "Reintentar").
  String? get ultimaPregunta {
    for (final m in mensajes.reversed) {
      if (m.rol == RolMensaje.usuario) return m.contenido;
    }
    return null;
  }

  AssistantState copyWith({
    EstadoAsistente? estado,
    List<MensajeAsistente>? mensajes,
    LimiteConsultas? limite,
    List<ItemOrden>? orden,
    String? respuestaId,
    bool? enviando,
    bool? agregando,
    PlanAgregado? planAgregado,
    int? planId,
    String? mensaje,
    String? aviso,
    int? avisoId,
  }) => AssistantState(
    estado: estado ?? this.estado,
    mensajes: mensajes ?? this.mensajes,
    limite: limite ?? this.limite,
    orden: orden ?? this.orden,
    respuestaId: respuestaId ?? this.respuestaId,
    enviando: enviando ?? this.enviando,
    agregando: agregando ?? this.agregando,
    planAgregado: planAgregado ?? this.planAgregado,
    planId: planId ?? this.planId,
    mensaje: mensaje ?? this.mensaje,
    aviso: aviso ?? this.aviso,
    avisoId: avisoId ?? this.avisoId,
  );

  @override
  List<Object?> get props => [
    estado,
    mensajes,
    limite,
    orden,
    respuestaId,
    enviando,
    agregando,
    planId,
    mensaje,
    aviso,
    avisoId,
  ];
}
