import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/completar_bloque.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/descartar_bloque.dart';

/// Qué terminó de pasar con el bloque (la pantalla reacciona una vez).
enum ResultadoBloque { ninguno, completado, descartado }

class StudyBlockState extends Equatable {
  const StudyBlockState({
    required this.bloque,
    this.actividad,
    this.procesando = false,
    this.error,
    this.resultado = ResultadoBloque.ninguno,
  });

  final BloqueEstudio bloque;

  /// La actividad que prepara el bloque ("Tarea vinculada"); nula mientras carga.
  final Actividad? actividad;

  /// true mientras se completa o se descarta.
  final bool procesando;
  final String? error;
  final ResultadoBloque resultado;

  StudyBlockState copyWith({
    BloqueEstudio? bloque,
    Actividad? actividad,
    bool? procesando,
    String? error,
    ResultadoBloque? resultado,
  }) => StudyBlockState(
    bloque: bloque ?? this.bloque,
    actividad: actividad ?? this.actividad,
    procesando: procesando ?? this.procesando,
    error: error,
    resultado: resultado ?? this.resultado,
  );

  @override
  List<Object?> get props => [bloque, actividad, procesando, error, resultado];
}

/// Maneja Bloque de estudio (Figma 27): carga la tarea vinculada y completa
/// o descarta el bloque en Supabase.
class StudyBlockCubit extends Cubit<StudyBlockState> {
  StudyBlockCubit(this._repositorio, BloqueEstudio bloque)
    : super(StudyBlockState(bloque: bloque));

  final StudyBlocksRepository _repositorio;

  Future<void> cargar() async {
    try {
      final actividad = await _repositorio.actividad(state.bloque.actividadId);
      emit(state.copyWith(actividad: actividad));
    } on AppException catch (e) {
      emit(state.copyWith(error: e.mensaje));
    }
  }

  Future<void> completar() async {
    if (state.procesando) return;
    emit(state.copyWith(procesando: true));
    try {
      await CompletarBloque(_repositorio)(state.bloque);
      emit(
        state.copyWith(
          procesando: false,
          bloque: _conEstado(state.bloque, EstadoBloque.completado),
          resultado: ResultadoBloque.completado,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(procesando: false, error: e.mensaje));
    }
  }

  Future<void> descartar() async {
    if (state.procesando) return;
    emit(state.copyWith(procesando: true));
    try {
      await DescartarBloque(_repositorio)(state.bloque);
      emit(
        state.copyWith(
          procesando: false,
          bloque: _conEstado(state.bloque, EstadoBloque.descartado),
          resultado: ResultadoBloque.descartado,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(procesando: false, error: e.mensaje));
    }
  }

  static BloqueEstudio _conEstado(BloqueEstudio b, EstadoBloque estado) =>
      BloqueEstudio(
        id: b.id,
        actividadId: b.actividadId,
        planId: b.planId,
        inicio: b.inicio,
        fin: b.fin,
        estado: estado,
        avisoMin: b.avisoMin,
        completadoEn: estado == EstadoBloque.completado ? DateTime.now() : null,
        actividadTitulo: b.actividadTitulo,
        materiaNombre: b.materiaNombre,
        materiaColorHex: b.materiaColorHex,
      );
}
