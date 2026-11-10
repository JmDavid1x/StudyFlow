import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/core/supabase/errores_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUp(() => traductorDeErrores = traducirErrorDeSupabase);
  tearDown(() => traductorDeErrores = null);

  test('un AppException se muestra tal cual', () {
    expect(mensajeDeError(const AppException('Elige tu universidad')), 'Elige tu universidad');
  });

  test('errores de Supabase Auth en español', () {
    expect(
      mensajeDeError(const AuthException('Invalid login credentials', code: 'invalid_credentials')),
      'Correo o contraseña incorrectos.',
    );
    expect(mensajeDeError(AuthRetryableFetchException()), contains('Sin conexión'));
  });

  test('errores de la base en español', () {
    expect(mensajeDeError(const PostgrestException(message: 'duplicate key', code: '23505')), 'Eso ya existe.');
    expect(mensajeDeError(const PostgrestException(message: 'rls', code: '42501')), contains('permiso'));
  });

  test('sin traductor registrado, un error desconocido da un mensaje genérico', () {
    traductorDeErrores = null;
    expect(mensajeDeError(StateError('x')), 'Algo salió mal. Intenta de nuevo.');
  });
}
