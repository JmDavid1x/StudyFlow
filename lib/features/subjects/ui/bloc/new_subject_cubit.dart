import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/usecases/guardar_materia.dart';

class NewSubjectState extends Equatable {
  const NewSubjectState({
    this.guardando = false,
    this.error,
    this.guardada = false,
  });

  final bool guardando;

  /// Mensaje listo para mostrar si no se pudo guardar.
  final String? error;
  final bool guardada;

  @override
  List<Object?> get props => [guardando, error, guardada];
}

/// Nueva materia (Figma 09 y S9).
class NewSubjectCubit extends Cubit<NewSubjectState> {
  NewSubjectCubit(this._guardarMateria) : super(const NewSubjectState());

  final GuardarMateria _guardarMateria;

  Future<void> guardar({
    required String nombre,
    String? profesor,
    required int creditos,
    required String colorHex,
    double? metaNota,
    required List<HorarioClase> horarios,
    required List<ComponenteNota> componentes,
  }) async {
    if (state.guardando) return;
    emit(const NewSubjectState(guardando: true));
    try {
      await _guardarMateria(
        nombre: nombre,
        profesor: profesor,
        creditos: creditos,
        colorHex: colorHex,
        metaNota: metaNota,
        horarios: horarios,
        componentes: componentes,
      );
      emit(const NewSubjectState(guardada: true));
    } on AppException catch (e) {
      emit(NewSubjectState(error: e.mensaje));
    } catch (e) {
      emit(NewSubjectState(error: mensajeDeError(e)));
    }
  }
}
