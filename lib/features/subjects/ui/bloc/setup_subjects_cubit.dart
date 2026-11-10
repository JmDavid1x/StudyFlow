import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';

sealed class SetupSubjectsState extends Equatable {
  const SetupSubjectsState();

  @override
  List<Object?> get props => [];
}

class SetupSubjectsLoading extends SetupSubjectsState {
  const SetupSubjectsLoading();
}

class SetupSubjectsLoaded extends SetupSubjectsState {
  const SetupSubjectsLoaded(this.materias);

  /// Puede estar vacía: aún no agregó ninguna.
  final List<Materia> materias;

  @override
  List<Object?> get props => [materias];
}

class SetupSubjectsError extends SetupSubjectsState {
  const SetupSubjectsError(this.mensaje);

  final String mensaje;

  @override
  List<Object?> get props => [mensaje];
}

/// Configuración inicial, paso 1 (Figma 08): las materias ya agregadas.
class SetupSubjectsCubit extends Cubit<SetupSubjectsState> {
  SetupSubjectsCubit(this._repositorio) : super(const SetupSubjectsLoading());

  final SubjectsRepository _repositorio;

  Future<void> cargar({bool mostrarCargando = true}) async {
    if (mostrarCargando || state is! SetupSubjectsLoaded)
      emit(const SetupSubjectsLoading());
    try {
      emit(SetupSubjectsLoaded(await _repositorio.materiasDelPeriodo()));
    } on AppException catch (e) {
      emit(SetupSubjectsError(e.mensaje));
    } catch (e) {
      emit(SetupSubjectsError(mensajeDeError(e)));
    }
  }
}
