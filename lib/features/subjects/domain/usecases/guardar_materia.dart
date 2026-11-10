import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subjects/domain/periodo_por_defecto.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';
import 'package:studyflow/features/subjects/domain/usecases/crear_materia.dart';

/// Guarda una materia nueva en el periodo activo. Si el usuario todavía no
/// tiene periodo (primera vez), crea el del semestre actual.
class GuardarMateria {
  GuardarMateria(this._repositorio, {DateTime Function()? reloj})
    : _reloj = reloj ?? DateTime.now;

  final SubjectsRepository _repositorio;
  final DateTime Function() _reloj;

  Future<Materia> call({
    required String nombre,
    String? profesor,
    required int creditos,
    required String colorHex,
    double? metaNota,
    required List<HorarioClase> horarios,
    required List<ComponenteNota> componentes,
  }) async {
    // Se valida antes de crear nada en la base (ni siquiera el periodo).
    Materia armar(String periodoId) => Materia(
      id: '',
      periodoId: periodoId,
      nombre: nombre.trim(),
      profesor: (profesor == null || profesor.trim().isEmpty)
          ? null
          : profesor.trim(),
      creditos: creditos,
      colorHex: colorHex,
      metaNota: metaNota,
    );
    validarNuevaMateria(armar(''), componentes);

    var periodo = await _repositorio.periodoActivo();
    if (periodo == null) {
      final datos = periodoPorDefecto(_reloj());
      periodo = await _repositorio.crearPeriodo(
        nombre: datos.nombre,
        fechaInicio: datos.fechaInicio,
        fechaFin: datos.fechaFin,
      );
    }
    return CrearMateria(_repositorio)(armar(periodo.id), horarios, componentes);
  }
}
