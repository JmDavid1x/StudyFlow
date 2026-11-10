import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/actividad_con_nota.dart';
import 'package:studyflow/features/subjects/domain/calculo_notas.dart';
import 'package:studyflow/features/subjects/domain/resumen_semestre.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';
import 'package:studyflow/features/subjects/ui/bloc/subject_detail_state.dart';

/// Detalle de una materia (Figma 22).
///
/// Si no recibe [materia] (la ruta se abrió sin argumento, por ejemplo desde
/// el menú de desarrollo), usa la primera materia del periodo activo.
class SubjectDetailCubit extends Cubit<SubjectDetailState> {
  SubjectDetailCubit(this._repositorio, {Materia? materia})
    : _materia = materia,
      super(const SubjectDetailLoading());

  final SubjectsRepository _repositorio;
  Materia? _materia;

  Future<void> cargar({bool mostrarCargando = true}) async {
    if (mostrarCargando || state is! SubjectDetailLoaded) {
      emit(const SubjectDetailLoading());
    }
    try {
      var materia = _materia;
      if (materia == null) {
        final materias = await _repositorio.materiasDelPeriodo();
        if (materias.isEmpty) {
          emit(const SubjectDetailEmpty());
          return;
        }
        materia = _materia = materias.first;
      }
      final actividades = await _repositorio.actividadesConNota(materia.id);
      emit(
        SubjectDetailLoaded(
          materia: materia,
          actividades: actividades,
          resumen: ResumenNotas.desde(
            meta: materia.metaNota,
            notas: actividades.ponderadas,
          ),
          componentes: resumenDeComponentes(materia.componentes, actividades),
        ),
      );
    } on AppException catch (e) {
      emit(SubjectDetailError(e.mensaje));
    } catch (e) {
      emit(SubjectDetailError(mensajeDeError(e)));
    }
  }
}
