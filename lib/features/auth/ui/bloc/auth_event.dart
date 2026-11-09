part of 'auth_bloc.dart';

/// Lo que la UI le pide al [AuthBloc].
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Se manda una vez al crear el Bloc: empieza a escuchar la sesión.
final class AuthIniciado extends AuthEvent {
  const AuthIniciado();
}

final class UniversidadesPedidas extends AuthEvent {
  const UniversidadesPedidas();
}

final class RegistroPedido extends AuthEvent {
  const RegistroPedido({
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.universidad,
  });

  final String nombre;
  final String correo;
  final String contrasena;
  final Universidad? universidad;

  // La contraseña no va en props: así nunca aparece en logs ni en comparaciones.
  @override
  List<Object?> get props => [nombre, correo, universidad];
}

final class InicioSesionPedido extends AuthEvent {
  const InicioSesionPedido({required this.correo, required this.contrasena});

  final String correo;
  final String contrasena;

  @override
  List<Object?> get props => [correo];
}

final class RecuperacionPedida extends AuthEvent {
  const RecuperacionPedida(this.correo);

  final String correo;

  @override
  List<Object?> get props => [correo];
}

final class CambioContrasenaPedido extends AuthEvent {
  const CambioContrasenaPedido({required this.nueva, required this.confirmacion});

  final String nueva;
  final String confirmacion;
}

/// Lo usa Perfil (Santiago) para cerrar sesión. El Bloc lleva al login.
final class CerrarSesionPedido extends AuthEvent {
  const CerrarSesionPedido();
}

/// Interno: Supabase avisó que cambió la sesión.
final class _SesionCambio extends AuthEvent {
  const _SesionCambio(this.evento);

  final EventoSesion evento;

  @override
  List<Object?> get props => [evento];
}
