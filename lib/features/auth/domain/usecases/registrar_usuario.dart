import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';
import 'package:studyflow/features/auth/domain/auth_validators.dart';
import 'package:studyflow/features/auth/domain/usecases/universidad_por_correo.dart';

/// Crear cuenta: valida los datos antes de llamar a Supabase, incluido que el
/// correo sea institucional de la universidad elegida.
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
    if (!correoEsDe(correo, universidad)) {
      throw AppException('Usa tu correo de ${universidad.nombre} (@${universidad.dominioCorreo})');
    }

    return _repository.registrar(
      nombre: nombre.trim(),
      correo: correo.trim().toLowerCase(),
      contrasena: contrasena,
      universidadId: universidad.id,
    );
  }
}
