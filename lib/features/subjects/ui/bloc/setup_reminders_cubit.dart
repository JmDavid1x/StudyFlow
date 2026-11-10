import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/usecases/terminar_configuracion.dart';

class SetupRemindersState extends Equatable {
  const SetupRemindersState({
    this.guardando = false,
    this.error,
    this.terminado = false,
  });

  final bool guardando;
  final String? error;

  /// La configuración quedó guardada: ya se puede ir a la app.
  final bool terminado;

  @override
  List<Object?> get props => [guardando, error, terminado];
}

/// Configuración inicial, paso 2 (Figma 10).
class SetupRemindersCubit extends Cubit<SetupRemindersState> {
  SetupRemindersCubit(this._terminar) : super(const SetupRemindersState());

  final TerminarConfiguracion _terminar;

  Future<void> terminar({required bool pushActivas}) async {
    if (state.guardando) return;
    emit(const SetupRemindersState(guardando: true));
    try {
      await _terminar(pushActivas: pushActivas);
      emit(const SetupRemindersState(terminado: true));
    } on AppException catch (e) {
      emit(SetupRemindersState(error: e.mensaje));
    } catch (e) {
      emit(SetupRemindersState(error: mensajeDeError(e)));
    }
  }
}
