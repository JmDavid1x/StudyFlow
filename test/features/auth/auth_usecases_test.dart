import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';
import 'package:studyflow/features/auth/domain/usecases/cambiar_contrasena.dart';
import 'package:studyflow/features/auth/domain/usecases/iniciar_sesion.dart';
import 'package:studyflow/features/auth/domain/usecases/obtener_universidades.dart';
import 'package:studyflow/features/auth/domain/usecases/recuperar_contrasena.dart';
import 'package:studyflow/features/auth/domain/usecases/registrar_usuario.dart';
import 'package:studyflow/features/auth/domain/usecases/universidad_por_correo.dart';

class _RepositorioFalso extends Mock implements AuthRepository {}

const _icesi = Universidad(id: 'u1', nombre: 'Universidad Icesi', dominioCorreo: 'u.icesi.edu.co');
const _uao = Universidad(id: 'u2', nombre: 'Universidad Autónoma de Occidente', dominioCorreo: 'uao.edu.co');

void main() {
  late _RepositorioFalso repositorio;

  setUp(() => repositorio = _RepositorioFalso());

  group('RegistrarUsuario', () {
    test('limpia los datos y llama al repositorio', () async {
      when(() => repositorio.registrar(
            nombre: any(named: 'nombre'),
            correo: any(named: 'correo'),
            contrasena: any(named: 'contrasena'),
            universidadId: any(named: 'universidadId'),
          )).thenAnswer((_) async => ResultadoRegistro.conSesion);

      final resultado = await RegistrarUsuario(repositorio)(
        nombre: '  Santiago García ',
        correo: ' Santiago@U.Icesi.edu.co ',
        contrasena: 'clave1234',
        universidadId: 'u1',
      );

      expect(resultado, ResultadoRegistro.conSesion);
      verify(() => repositorio.registrar(
            nombre: 'Santiago García',
            correo: 'santiago@u.icesi.edu.co',
            contrasena: 'clave1234',
            universidadId: 'u1',
          )).called(1);
    });

    test('no llama a Supabase si la contraseña es débil', () {
      expect(
        () => RegistrarUsuario(repositorio)(
          nombre: 'Ana',
          correo: 'ana@u.icesi.edu.co',
          contrasena: 'corta',
          universidadId: 'u1',
        ),
        throwsA(isA<AppException>()),
      );
      verifyNever(() => repositorio.registrar(
            nombre: any(named: 'nombre'),
            correo: any(named: 'correo'),
            contrasena: any(named: 'contrasena'),
            universidadId: any(named: 'universidadId'),
          ));
    });

    test('pide la universidad', () {
      expect(
        () => RegistrarUsuario(repositorio)(
          nombre: 'Ana',
          correo: 'ana@u.icesi.edu.co',
          contrasena: 'clave1234',
          universidadId: null,
        ),
        throwsA(isA<AppException>().having((e) => e.mensaje, 'mensaje', 'Elige tu universidad')),
      );
    });
  });

  test('IniciarSesion valida antes de llamar', () async {
    when(() => repositorio.iniciarSesion(correo: any(named: 'correo'), contrasena: any(named: 'contrasena')))
        .thenAnswer((_) async {});

    expect(() => IniciarSesion(repositorio)(correo: 'sin-arroba', contrasena: 'x'), throwsA(isA<AppException>()));
    await IniciarSesion(repositorio)(correo: 'Ana@uao.edu.co', contrasena: 'clave1234');
    verify(() => repositorio.iniciarSesion(correo: 'ana@uao.edu.co', contrasena: 'clave1234')).called(1);
  });

  test('RecuperarContrasena devuelve el correo limpio', () async {
    when(() => repositorio.recuperarContrasena(any())).thenAnswer((_) async {});
    final correo = await RecuperarContrasena(repositorio)(' Ana@UAO.edu.co ');
    expect(correo, 'ana@uao.edu.co');
  });

  test('CambiarContrasena exige que coincidan', () {
    expect(
      () => CambiarContrasena(repositorio)(nueva: 'clave1234', confirmacion: 'clave12345'),
      throwsA(isA<AppException>().having((e) => e.mensaje, 'mensaje', 'Las contraseñas no coinciden')),
    );
  });

  test('ObtenerUniversidades las ordena por nombre', () async {
    when(() => repositorio.universidades()).thenAnswer((_) async => [_icesi, _uao]);
    final lista = await ObtenerUniversidades(repositorio)();
    expect(lista.first, _uao);
  });

  test('universidadPorCorreo detecta el dominio', () {
    expect(universidadPorCorreo('juan@u.icesi.edu.co', [_icesi, _uao]), _icesi);
    expect(universidadPorCorreo('juan@gmail.com', [_icesi, _uao]), isNull);
  });
}
