import 'package:studyflow/features/auth/domain/auth_repository.dart';

class CerrarSesion {
  const CerrarSesion(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.cerrarSesion();
}
