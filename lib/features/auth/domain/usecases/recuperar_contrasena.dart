import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';
import 'package:studyflow/features/auth/domain/auth_validators.dart';

/// Pide el correo de recuperación y devuelve el correo limpio, para mostrarlo
/// en la pantalla "Revisa tu correo".
class RecuperarContrasena {
  const RecuperarContrasena(this._repository);

  final AuthRepository _repository;

  Future<String> call(String correo) async {
    final error = AuthValidators.email(correo);
    if (error != null) throw AppException(error);
    final limpio = correo.trim().toLowerCase();
    await _repository.recuperarContrasena(limpio);
    return limpio;
  }
}
