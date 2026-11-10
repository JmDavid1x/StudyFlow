import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';

/// Descarta un bloque pendiente: libera ese tiempo. La actividad no se toca.
class DescartarBloque {
  const DescartarBloque(this._repositorio);

  final StudyBlocksRepository _repositorio;

  Future<void> call(BloqueEstudio bloque) async {
    if (bloque.estado != EstadoBloque.pendiente) {
      throw const AppException('Este bloque ya no está pendiente.');
    }
    await _repositorio.descartarBloque(bloque.id);
  }
}
