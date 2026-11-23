import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';
import 'package:studyflow/features/auth/domain/auth_validators.dart';

/// Crear cuenta: valida los datos antes de llamar a Supabase. Se acepta
/// cualquier correo (institucional, Gmail, Hotmail…); la universidad la elige
/// el estudiante y, si el correo es institucional, la base la toma del dominio.
class RegistrarUsuario {
  const RegistrarUsuario(this._repository);

  final AuthRepository _repository;

  Future<ResultadoRegistro> call({
    required String nombre,
    required String correo,
    required String contrasena,
    required Universidad? universidad,
  }) async {
    final error = AuthValidators.name(nombre) ?? AuthValidators.email(correo) ?? AuthValidators.newPassword(contrasena);
    if (error != null) throw AppException(error);
    if (universidad == null) throw const AppException('Elige tu universidad');

    return _repository.registrar(
      nombre: nombre.trim(),
      correo: correo.trim().toLowerCase(),
      contrasena: contrasena,
      universidadId: universidad.id,
    );
  }
}
