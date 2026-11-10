import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/calculo_notas.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';

/// Guarda la nota de una actividad (0.0 a 5.0, con un decimal).
class RegistrarNota {
  const RegistrarNota(this._repositorio);

  final SubjectsRepository _repositorio;

  Future<void> call(String actividadId, double nota) {
    if (!notaValida(nota)) {
      throw const AppException('La nota debe estar entre 0.0 y 5.0.');
    }
    // La columna es numeric(2,1): un solo decimal.
    final redondeada = (nota * 10).round() / 10;
    return _repositorio.registrarNota(actividadId, redondeada);
  }
}
