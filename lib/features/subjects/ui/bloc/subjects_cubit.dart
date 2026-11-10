import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/usecases/obtener_resumen_semestre.dart';
import 'package:studyflow/features/subjects/ui/bloc/subjects_state.dart';

/// Pestaña Materias (Figma 21).
class SubjectsCubit extends Cubit<SubjectsState> {
  SubjectsCubit(this._obtenerResumen) : super(const SubjectsLoading());

  final ObtenerResumenSemestre _obtenerResumen;

  /// Carga (o recarga) las materias. Con [mostrarCargando] en false no
  /// parpadea la pantalla al refrescar al volver de otra pantalla.
  Future<void> cargar({bool mostrarCargando = true}) async {
    if (mostrarCargando || state is! SubjectsLoaded) {
      emit(const SubjectsLoading());
    }
    try {
      final resumen = await _obtenerResumen();
      emit(resumen.vacio ? const SubjectsEmpty() : SubjectsLoaded(resumen));
    } on AppException catch (e) {
      emit(SubjectsError(e.mensaje));
    } catch (e) {
      emit(SubjectsError(mensajeDeError(e)));
    }
  }
}
