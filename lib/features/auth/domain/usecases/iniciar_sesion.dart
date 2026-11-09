import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';
import 'package:studyflow/features/auth/domain/auth_validators.dart';

class IniciarSesion {
  const IniciarSesion(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String correo, required String contrasena}) async {
    final error = AuthValidators.email(correo) ?? AuthValidators.password(contrasena);
    if (error != null) throw AppException(error);
    await _repository.iniciarSesion(correo: correo.trim().toLowerCase(), contrasena: contrasena);
  }
}
