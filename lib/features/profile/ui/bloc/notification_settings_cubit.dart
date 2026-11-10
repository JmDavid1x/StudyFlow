import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/profile/domain/profile_repository.dart';

/// En qué va la pantalla de ajustes.
enum EstadoAjustes { cargando, listo, error, guardando, guardado }

class NotificationSettingsState extends Equatable {
  const NotificationSettingsState({
    this.estado = EstadoAjustes.cargando,
    this.ajustes,
    this.mensaje,
    this.aviso,
    this.avisoId = 0,
  });

  final EstadoAjustes estado;

  /// Los ajustes con los cambios que el usuario va haciendo (aún sin guardar).
  final AjustesNotificacion? ajustes;

  /// Error de la carga (estado error).
  final String? mensaje;

  /// Error al guardar, para un SnackBar. [avisoId] cambia cada vez.
  final String? aviso;
  final int avisoId;

  NotificationSettingsState copyWith({
    EstadoAjustes? estado,
    AjustesNotificacion? ajustes,
    String? mensaje,
    String? aviso,
    int? avisoId,
  }) => NotificationSettingsState(
    estado: estado ?? this.estado,
    ajustes: ajustes ?? this.ajustes,
    mensaje: mensaje ?? this.mensaje,
    aviso: aviso ?? this.aviso,
    avisoId: avisoId ?? this.avisoId,
  );

  @override
  List<Object?> get props => [estado, ajustes, mensaje, aviso, avisoId];
}

/// Ajustes de notificaciones (Figma 26): lee la fila del usuario, deja
/// cambiarla en pantalla y la guarda con un update.
class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  NotificationSettingsCubit(this._repositorio)
    : super(const NotificationSettingsState());

  final ProfileRepository _repositorio;

  Future<void> cargar() async {
    emit(state.copyWith(estado: EstadoAjustes.cargando));
    try {
      final ajustes = await _repositorio.ajustes();
      emit(state.copyWith(estado: EstadoAjustes.listo, ajustes: ajustes));
    } catch (e) {
      emit(
        state.copyWith(estado: EstadoAjustes.error, mensaje: mensajeDeError(e)),
      );
    }
  }

  /// Un interruptor o selector cambió (solo en pantalla, hasta guardar).
  void cambiar(AjustesNotificacion ajustes) {
    emit(state.copyWith(ajustes: ajustes));
  }

  /// "Guardar cambios". Si sale bien queda en [EstadoAjustes.guardado] y la
  /// pantalla vuelve atrás.
  Future<void> guardar() async {
    final ajustes = state.ajustes;
    if (ajustes == null || state.estado == EstadoAjustes.guardando) return;
    emit(state.copyWith(estado: EstadoAjustes.guardando));
    try {
      await _repositorio.guardarAjustes(ajustes);
      emit(state.copyWith(estado: EstadoAjustes.guardado));
    } catch (e) {
      emit(
        state.copyWith(
          estado: EstadoAjustes.listo,
          aviso: mensajeDeError(e),
          avisoId: state.avisoId + 1,
        ),
      );
    }
  }
}
