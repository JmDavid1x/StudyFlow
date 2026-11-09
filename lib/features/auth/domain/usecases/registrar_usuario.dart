import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';
import 'package:studyflow/features/auth/domain/auth_validators.dart';

/// Crear cuenta: valida los datos antes de llamar a Supabase.
class RegistrarUsuario {
  const RegistrarUsuario(this._repository);

  final AuthRepository _repository;

  Future<ResultadoRegistro> call({
    required String nombre,
    required String correo,
    required String contrasena,
    required String? universidadId,
  }) {
    final error = AuthValidators.name(nombre) ??
        AuthValidators.email(correo) ??
        AuthValidators.newPassword(contrasena) ??
        (universidadId == null ? 'Elige tu universidad' : null);
    if (error != null) throw AppException(error);

    return _repository.registrar(
      nombre: nombre.trim(),
      correo: correo.trim().toLowerCase(),
      contrasena: contrasena,
      universidadId: universidadId!,
    );
  }
}
