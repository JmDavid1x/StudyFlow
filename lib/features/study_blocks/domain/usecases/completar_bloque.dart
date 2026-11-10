import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';

/// Marca un bloque como completado. Si su actividad seguía en por_hacer,
/// pasa a en_progreso (ya se empezó a trabajar en ella). Completar un bloque
/// nunca completa la actividad: eso lo hace el usuario en el detalle.
class CompletarBloque {
  const CompletarBloque(this._repositorio);

  final StudyBlocksRepository _repositorio;

  Future<void> call(BloqueEstudio bloque) async {
    if (bloque.estado != EstadoBloque.pendiente) {
      throw const AppException('Este bloque ya no está pendiente.');
    }
    await _repositorio.completarBloque(bloque.id);
    final estado = await _repositorio.estadoDeActividad(bloque.actividadId);
    if (estado == EstadoActividad.porHacer) {
      await _repositorio.marcarActividadEnProgreso(bloque.actividadId);
    }
  }
}
