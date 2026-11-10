import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/calculo_notas.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';

/// Crea una materia validando antes las reglas del modelo de datos.
class CrearMateria {
  const CrearMateria(this._repositorio);

  final SubjectsRepository _repositorio;

  Future<Materia> call(
    Materia materia,
    List<HorarioClase> horarios,
    List<ComponenteNota> componentes,
  ) {
    if (materia.nombre.trim().isEmpty) {
      throw const AppException('Escribe el nombre de la materia.');
    }
    final meta = materia.metaNota;
    if (meta != null && !notaValida(meta)) {
      throw const AppException('La meta debe estar entre 0.0 y 5.0.');
    }
    if (!componentesSuman100(componentes.map((c) => c.porcentaje))) {
      throw const AppException('Los componentes de la nota deben sumar 100 %.');
    }
    return _repositorio.crearMateria(materia, horarios, componentes);
  }
}
