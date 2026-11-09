import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';

/// [AuthRepository] con Supabase Auth.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._db);

  final SupabaseClient _db;

  @override
  Stream<EventoSesion> get eventos => _db.auth.onAuthStateChange
      .map((cambio) => switch (cambio.event) {
            AuthChangeEvent.passwordRecovery => EventoSesion.recuperacion,
            AuthChangeEvent.signedOut => EventoSesion.cierre,
            _ => cambio.session == null ? EventoSesion.cierre : EventoSesion.inicio,
          })
      .distinct();

  @override
  bool get haySesion => _db.auth.currentSession != null;

  @override
  Future<List<Universidad>> universidades() => _intentar(() async {
        final filas = await _db.from('universidades').select();
        return filas.map(Universidad.fromMap).toList();
      });

  @override
  Future<ResultadoRegistro> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
    required String universidadId,
  }) =>
      _intentar(() async {
        final respuesta = await _db.auth.signUp(
          email: correo,
          password: contrasena,
          // El trigger de la base lee estos datos para crear el perfil.
          data: {'nombre': nombre, 'universidad_id': universidadId},
        );
        return respuesta.session == null ? ResultadoRegistro.confirmarCorreo : ResultadoRegistro.conSesion;
      });

  @override
  Future<void> iniciarSesion({required String correo, required String contrasena}) =>
      _intentar(() => _db.auth.signInWithPassword(email: correo, password: contrasena));

  @override
  Future<void> recuperarContrasena(String correo) =>
      _intentar(() => _db.auth.resetPasswordForEmail(correo));

  @override
  Future<void> cambiarContrasena(String nueva) =>
      _intentar(() => _db.auth.updateUser(UserAttributes(password: nueva)));

  @override
  Future<void> cerrarSesion() => _intentar(() => _db.auth.signOut());

  @override
  Future<Perfil?> perfilActual() => _intentar(() async {
        final usuario = _db.auth.currentUser;
        if (usuario == null) return null;
        final fila = await _db.from('perfiles').select(Perfil.select).eq('id', usuario.id).maybeSingle();
        return fila == null ? null : Perfil.fromMap(fila);
      });

  /// Convierte cualquier error de Supabase en un [AppException] en español.
  Future<T> _intentar<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }
}
