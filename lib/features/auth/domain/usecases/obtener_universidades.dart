import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';

/// Universidades del registro, ordenadas por nombre.
class ObtenerUniversidades {
  const ObtenerUniversidades(this._repository);

  final AuthRepository _repository;

  Future<List<Universidad>> call() async {
    final lista = await _repository.universidades();
    return [...lista]..sort((a, b) => a.nombre.compareTo(b.nombre));
  }
}
