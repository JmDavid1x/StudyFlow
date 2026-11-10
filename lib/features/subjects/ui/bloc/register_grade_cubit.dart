import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/actividad_con_nota.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';
import 'package:studyflow/features/subjects/domain/usecases/registrar_nota.dart';
import 'package:studyflow/features/subjects/ui/bloc/register_grade_state.dart';

/// Registrar nota (Figma 23 y S3).
///
/// Recibe una [materia] (desde el detalle) o una [actividad] (desde el detalle
/// de examen, que se deja preseleccionada). Sin ninguna de las dos usa la
/// primera materia del periodo, así la pantalla no se rompe.
class RegisterGradeCubit extends Cubit<RegisterGradeState> {
  RegisterGradeCubit(
    this._repositorio, {
    Materia? materia,
    Actividad? actividad,
  }) : _materia = materia,
       _actividad = actividad,
       super(const RegisterGradeLoading());

  static const _notaInicial = 30;

  final SubjectsRepository _repositorio;
  final Actividad? _actividad;
  Materia? _materia;

  Future<void> cargar() async {
    emit(const RegisterGradeLoading());
    try {
      final materia = _materia ??= await _buscarMateria();
      if (materia == null) {
        emit(
          const RegisterGradeEmpty(
            'Aún no tienes materias. Agrega una para registrar notas.',
          ),
        );
        return;
      }
      final actividades = await _repositorio.actividadesConNota(materia.id);
      if (actividades.isEmpty) {
        emit(
          const RegisterGradeEmpty(
            'Esta materia aún no tiene actividades. Agrega una tarea para ponerle nota.',
          ),
        );
        return;
      }
      final elegida =
          actividades
              .where((a) => a.actividad.id == _actividad?.id)
              .firstOrNull ??
          actividades.where((a) => !a.tieneNota).firstOrNull ??
          actividades.first;
      emit(
        RegisterGradeReady(
          materia: materia,
          actividades: actividades,
          componenteId: elegida.actividad.componenteId,
          actividadId: elegida.actividad.id,
          decimas: _decimasDe(elegida, _notaInicial),
        ),
      );
    } on AppException catch (e) {
      emit(RegisterGradeError(e.mensaje));
    } catch (e) {
      emit(RegisterGradeError(mensajeDeError(e)));
    }
  }

  Future<Materia?> _buscarMateria() async {
    final materias = await _repositorio.materiasDelPeriodo();
    final actividad = _actividad;
    if (actividad != null) {
      final suya = materias
          .where(
            (m) =>
                m.id == actividad.materiaId ||
                m.componentes.any((c) => c.id == actividad.componenteId),
          )
          .firstOrNull;
      if (suya != null) return suya;
    }
    return materias.firstOrNull;
  }

  int _decimasDe(ActividadConNota a, int porDefecto) =>
      a.tieneNota ? (a.calificacion!.nota * 10).round() : porDefecto;

  void elegirComponente(String componenteId) {
    final actual = state;
    if (actual is! RegisterGradeReady) return;
    final delComponente = actual.actividades
        .where((a) => a.actividad.componenteId == componenteId)
        .toList();
    final elegida =
        delComponente.where((a) => !a.tieneNota).firstOrNull ??
        delComponente.firstOrNull;
    emit(
      elegida == null
          ? actual.copyWith(componenteId: componenteId, sinActividad: true)
          : actual.copyWith(
              componenteId: componenteId,
              actividadId: elegida.actividad.id,
              decimas: _decimasDe(elegida, actual.decimas),
            ),
    );
  }

  void elegirActividad(String actividadId) {
    final actual = state;
    if (actual is! RegisterGradeReady) return;
    final elegida = actual.actividades
        .where((a) => a.actividad.id == actividadId)
        .firstOrNull;
    if (elegida == null) return;
    emit(
      actual.copyWith(
        actividadId: actividadId,
        decimas: _decimasDe(elegida, actual.decimas),
      ),
    );
  }

  void cambiarDecimas(int decimas) {
    final actual = state;
    if (actual is! RegisterGradeReady) return;
    emit(actual.copyWith(decimas: decimas.clamp(0, 50).toInt()));
  }

  Future<void> guardar() async {
    final actual = state;
    if (actual is! RegisterGradeReady || !actual.puedeGuardar) return;
    emit(actual.copyWith(guardando: true, sinError: true));
    try {
      await RegistrarNota(_repositorio)(actual.actividadId!, actual.nota);
      final actividades = await _repositorio.actividadesConNota(
        actual.materia.id,
      );
      emit(
        actual.copyWith(
          actividades: actividades,
          guardando: false,
          sinError: true,
          guardada: NotaGuardada(
            materiaNombre: actual.materia.nombre,
            antes: actual.antes.notaAcumulada,
            despues: actual.despues?.notaAcumulada,
          ),
        ),
      );
    } on AppException catch (e) {
      emit(actual.copyWith(guardando: false, errorAlGuardar: e.mensaje));
    } catch (e) {
      emit(
        actual.copyWith(guardando: false, errorAlGuardar: mensajeDeError(e)),
      );
    }
  }
}
