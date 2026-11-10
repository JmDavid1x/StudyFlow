import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/profile/domain/profile_repository.dart';
import 'package:studyflow/features/profile/domain/usecases/cargar_perfil.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';

/// En qué va la carga del perfil.
enum EstadoPerfil { cargando, listo, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.estado = EstadoPerfil.cargando,
    this.resumen,
    this.mensaje,
  });

  final EstadoPerfil estado;
  final ResumenPerfil? resumen;

  /// Error de la carga (estado error).
  final String? mensaje;

  ProfileState copyWith({
    EstadoPerfil? estado,
    ResumenPerfil? resumen,
    String? mensaje,
  }) => ProfileState(
    estado: estado ?? this.estado,
    resumen: resumen ?? this.resumen,
    mensaje: mensaje ?? this.mensaje,
  );

  // ResumenPerfil no es Equatable: cada carga cuenta como estado nuevo.
  @override
  List<Object?> get props => [estado, resumen, mensaje];
}

/// Pestaña Perfil (Figma 25): datos de la cuenta, plan actual y consultas
/// usadas. Se crea en ProfileScreen. Cerrar sesión lo hace el AuthBloc.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    ProfileRepository perfiles,
    SubscriptionRepository suscripciones, {
    DateTime Function()? reloj,
  }) : _cargar = CargarPerfil(perfiles, suscripciones),
       _reloj = reloj ?? DateTime.now,
       super(const ProfileState());

  final CargarPerfil _cargar;
  final DateTime Function() _reloj;

  /// Carga (o recarga al volver de otra pantalla). Al recargar, lo de antes
  /// sigue visible mientras llega lo nuevo.
  Future<void> cargar() async {
    if (state.estado != EstadoPerfil.listo) {
      emit(state.copyWith(estado: EstadoPerfil.cargando));
    }
    try {
      final resumen = await _cargar(_reloj());
      emit(state.copyWith(estado: EstadoPerfil.listo, resumen: resumen));
    } catch (e) {
      // Si ya había datos, se dejan; si no, se muestra el error.
      if (state.estado == EstadoPerfil.listo) return;
      emit(
        state.copyWith(estado: EstadoPerfil.error, mensaje: mensajeDeError(e)),
      );
    }
  }
}
