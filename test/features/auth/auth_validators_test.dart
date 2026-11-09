import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/features/auth/domain/auth_validators.dart';

void main() {
  test('correo', () {
    expect(AuthValidators.email(''), 'Escribe tu correo');
    expect(AuthValidators.email('ana'), isNotNull);
    expect(AuthValidators.email('ana@icesi'), isNotNull);
    expect(AuthValidators.email('ana@u.icesi.edu.co.'), isNotNull);
    expect(AuthValidators.email(' ana@u.icesi.edu.co '), isNull);
  });

  test('contraseña nueva: 8 caracteres y un número', () {
    expect(AuthValidators.newPassword(''), 'Escribe una contraseña');
    expect(AuthValidators.newPassword('clave12'), isNotNull);
    expect(AuthValidators.newPassword('clavesinnumero'), isNotNull);
    expect(AuthValidators.newPassword('clave1234'), isNull);
  });

  test('nombre y contraseña de login', () {
    expect(AuthValidators.name('   '), 'Escribe tu nombre');
    expect(AuthValidators.name('Ana'), isNull);
    expect(AuthValidators.password(''), 'Escribe tu contraseña');
  });
}
