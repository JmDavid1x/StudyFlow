import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';
import 'package:studyflow/features/auth/domain/auth_validators.dart';

/// Contraseña nueva después de abrir el enlace del correo.
class CambiarContrasena {
  const CambiarContrasena(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String nueva, required String confirmacion}) {
    final error = AuthValidators.newPassword(nueva) ??
        (nueva != confirmacion ? 'Las contraseñas no coinciden' : null);
    if (error != null) throw AppException(error);
    return _repository.cambiarContrasena(nueva);
  }
}
