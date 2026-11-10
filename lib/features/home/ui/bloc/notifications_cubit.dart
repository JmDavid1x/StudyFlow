import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/home/domain/home_repository.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';

/// En qué va la carga de la bandeja.
enum EstadoNotificaciones { cargando, listo, error }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.estado = EstadoNotificaciones.cargando,
    this.notificaciones = const [],
    this.ahora,
    this.mensaje,
    this.aviso,
    this.avisoId = 0,
  });

  final EstadoNotificaciones estado;

  /// Solo las que ya llegaron (programada_para ≤ ahora), la más reciente primero.
  final List<Notificacion> notificaciones;
  final DateTime? ahora;

  /// Error de la carga (estado error).
  final String? mensaje;

  /// Error de una acción, para un SnackBar. [avisoId] cambia cada vez.
  final String? aviso;
  final int avisoId;

  NotificationsState copyWith({
    EstadoNotificaciones? estado,
    List<Notificacion>? notificaciones,
    DateTime? ahora,
    String? mensaje,
    String? aviso,
    int? avisoId,
  }) => NotificationsState(
    estado: estado ?? this.estado,
    notificaciones: notificaciones ?? this.notificaciones,
    ahora: ahora ?? this.ahora,
    mensaje: mensaje ?? this.mensaje,
    aviso: aviso ?? this.aviso,
    avisoId: avisoId ?? this.avisoId,
  );

  @override
  List<Object?> get props => [estado, notificaciones, ahora, mensaje, aviso, avisoId];
}

/// Notificaciones (Figma 13): leer la bandeja, marcar leída al tocar y
/// borrar al deslizar. Se crea en NotificationsScreen.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._inicio, this._tareas, {DateTime Function()? reloj})
    : _reloj = reloj ?? DateTime.now,
      super(const NotificationsState());

  final HomeRepository _inicio;
  final TasksRepository _tareas;
  final DateTime Function() _reloj;

  Future<void> cargar() async {
    if (state.estado != EstadoNotificaciones.listo) emit(state.copyWith(estado: EstadoNotificaciones.cargando));
    try {
      final ahora = _reloj();
      final todas = await _inicio.notificaciones();
      emit(
        state.copyWith(
          estado: EstadoNotificaciones.listo,
          ahora: ahora,
          // Las programadas para más tarde todavía no se muestran.
          notificaciones: todas.where((n) => !n.programadaPara.isAfter(ahora)).toList(),
        ),
      );
    } catch (e) {
      if (state.estado == EstadoNotificaciones.listo) {
        _avisar(e);
      } else {
        emit(state.copyWith(estado: EstadoNotificaciones.error, mensaje: mensajeDeError(e)));
      }
    }
  }

  /// Marca el aviso como leído y devuelve su actividad para abrirla (nula si
  /// no menciona una o ya no existe).
  Future<Actividad?> tocar(Notificacion notificacion) async {
    if (!notificacion.leida) {
      final leida = _conLeidaEn(notificacion, _reloj());
      emit(state.copyWith(notificaciones: [for (final n in state.notificaciones) n.id == leida.id ? leida : n]));
      try {
        await _inicio.marcarLeida(notificacion.id);
      } catch (e) {
        // No se pudo guardar: vuelve a verse sin leer.
        emit(
          state.copyWith(
            notificaciones: [for (final n in state.notificaciones) n.id == notificacion.id ? notificacion : n],
          ),
        );
        _avisar(e);
      }
    }
    final actividadId = notificacion.actividadId;
    if (actividadId == null) return null;
    try {
      final actividad = await _tareas.actividadPorId(actividadId);
      if (actividad == null) _avisar(const AppException('Esta actividad ya no existe.'));
      return actividad;
    } catch (e) {
      _avisar(e);
      return null;
    }
  }

  /// La quita de la lista enseguida (la fila ya se deslizó) y la borra en la
  /// base. Si falla, vuelve a su lugar.
  Future<void> borrar(Notificacion notificacion) async {
    final antes = state.notificaciones;
    emit(state.copyWith(notificaciones: antes.where((n) => n.id != notificacion.id).toList()));
    try {
      await _inicio.borrarNotificacion(notificacion.id);
    } catch (e) {
      emit(state.copyWith(notificaciones: antes));
      _avisar(e);
    }
  }

  void _avisar(Object e) => emit(state.copyWith(aviso: mensajeDeError(e), avisoId: state.avisoId + 1));

  static Notificacion _conLeidaEn(Notificacion n, DateTime leidaEn) => Notificacion(
    id: n.id,
    perfilId: n.perfilId,
    actividadId: n.actividadId,
    bloqueId: n.bloqueId,
    tipo: n.tipo,
    titulo: n.titulo,
    cuerpo: n.cuerpo,
    programadaPara: n.programadaPara,
    enviadaEn: n.enviadaEn,
    leidaEn: leidaEn,
  );
}
