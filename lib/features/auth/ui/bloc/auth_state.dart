part of 'auth_bloc.dart';

/// Si hay alguien con sesión.
enum Sesion { desconocida, activa, cerrada, recuperacion }

/// Qué acción de las pantallas de acceso se está haciendo.
enum AccionAuth { ninguna, registro, inicioSesion, recuperacion, cambioContrasena, cierreSesion }

/// En qué va esa acción.
enum EstadoAccion { inactiva, cargando, exito, error }

class AuthState extends Equatable {
  const AuthState({
    this.sesion = Sesion.desconocida,
    this.accion = AccionAuth.ninguna,
    this.estado = EstadoAccion.inactiva,
    this.mensaje,
    this.universidades = const [],
    this.perfil,
    this.correoEnviado,
    this.resultadoRegistro,
  });

  final Sesion sesion;
  final AccionAuth accion;
  final EstadoAccion estado;

  /// Error para mostrar (ya viene en español).
  final String? mensaje;
  final List<Universidad> universidades;

  /// Perfil del usuario con sesión (para saber si terminó la configuración).
  final Perfil? perfil;

  /// Correo al que se mandó el enlace de recuperación.
  final String? correoEnviado;
  final ResultadoRegistro? resultadoRegistro;

  bool cargando(AccionAuth a) => accion == a && estado == EstadoAccion.cargando;
  bool exito(AccionAuth a) => accion == a && estado == EstadoAccion.exito;
  bool error(AccionAuth a) => accion == a && estado == EstadoAccion.error;

  AuthState copyWith({
    Sesion? sesion,
    AccionAuth? accion,
    EstadoAccion? estado,
    String? mensaje,
    List<Universidad>? universidades,
    Perfil? perfil,
    String? correoEnviado,
    ResultadoRegistro? resultadoRegistro,
  }) =>
      AuthState(
        sesion: sesion ?? this.sesion,
        accion: accion ?? this.accion,
        estado: estado ?? this.estado,
        // El mensaje solo vive en el estado de error en que se creó.
        mensaje: mensaje,
        universidades: universidades ?? this.universidades,
        perfil: perfil ?? this.perfil,
        correoEnviado: correoEnviado ?? this.correoEnviado,
        resultadoRegistro: resultadoRegistro ?? this.resultadoRegistro,
      );

  @override
  List<Object?> get props =>
      [sesion, accion, estado, mensaje, universidades, perfil, correoEnviado, resultadoRegistro];
}
