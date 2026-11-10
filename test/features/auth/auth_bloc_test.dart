import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';
import 'package:studyflow/features/auth/ui/bloc/auth_bloc.dart';

class _RepositorioFalso extends Mock implements AuthRepository {}

final _perfil = Perfil(
  id: 'u1',
  universidadId: 'icesi',
  nombre: 'Ana Gómez',
  correo: 'ana@u.icesi.edu.co',
  configuracionCompleta: true,
  creadoEn: DateTime(2026, 11, 1),
);

const _icesi = Universidad(id: 'icesi', nombre: 'Universidad Icesi', dominioCorreo: 'u.icesi.edu.co');

void main() {
  late _RepositorioFalso repositorio;
  late StreamController<EventoSesion> sesion;

  setUp(() {
    repositorio = _RepositorioFalso();
    sesion = StreamController<EventoSesion>.broadcast();
    when(() => repositorio.eventos).thenAnswer((_) => sesion.stream);
    when(() => repositorio.haySesion).thenReturn(false);
  });

  tearDown(() => sesion.close());

  group('al abrir la app', () {
    blocTest<AuthBloc, AuthState>(
      'sin sesión guardada queda cerrada',
      build: () => AuthBloc(repositorio),
      act: (bloc) => bloc.add(const AuthIniciado()),
      expect: () => [const AuthState(sesion: Sesion.cerrada)],
    );

    blocTest<AuthBloc, AuthState>(
      'con sesión guardada trae el perfil (para que el Splash decida)',
      setUp: () {
        when(() => repositorio.haySesion).thenReturn(true);
        when(() => repositorio.perfilActual()).thenAnswer((_) async => _perfil);
      },
      build: () => AuthBloc(repositorio),
      act: (bloc) => bloc.add(const AuthIniciado()),
      expect: () => [AuthState(sesion: Sesion.activa, perfil: _perfil)],
    );
  });

  group('iniciar sesión', () {
    blocTest<AuthBloc, AuthState>(
      'bien: cargando y luego éxito con el perfil',
      setUp: () {
        when(() => repositorio.iniciarSesion(correo: any(named: 'correo'), contrasena: any(named: 'contrasena')))
            .thenAnswer((_) async {});
        when(() => repositorio.perfilActual()).thenAnswer((_) async => _perfil);
      },
      build: () => AuthBloc(repositorio),
      act: (bloc) => bloc.add(const InicioSesionPedido(correo: 'ana@u.icesi.edu.co', contrasena: 'clave1234')),
      expect: () => [
        const AuthState(accion: AccionAuth.inicioSesion, estado: EstadoAccion.cargando),
        AuthState(accion: AccionAuth.inicioSesion, estado: EstadoAccion.exito, perfil: _perfil),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'mal: muestra el mensaje en español',
      setUp: () {
        when(() => repositorio.iniciarSesion(correo: any(named: 'correo'), contrasena: any(named: 'contrasena')))
            .thenThrow(const AppException('Correo o contraseña incorrectos.'));
      },
      build: () => AuthBloc(repositorio),
      act: (bloc) => bloc.add(const InicioSesionPedido(correo: 'ana@u.icesi.edu.co', contrasena: 'mala1234')),
      expect: () => [
        const AuthState(accion: AccionAuth.inicioSesion, estado: EstadoAccion.cargando),
        const AuthState(
          accion: AccionAuth.inicioSesion,
          estado: EstadoAccion.error,
          mensaje: 'Correo o contraseña incorrectos.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'si el perfil no carga, igual entra (no muestra un error falso)',
      setUp: () {
        when(() => repositorio.iniciarSesion(correo: any(named: 'correo'), contrasena: any(named: 'contrasena')))
            .thenAnswer((_) async {});
        when(() => repositorio.perfilActual()).thenThrow(const AppException('Sin conexión.'));
      },
      build: () => AuthBloc(repositorio),
      act: (bloc) => bloc.add(const InicioSesionPedido(correo: 'ana@u.icesi.edu.co', contrasena: 'clave1234')),
      expect: () => [
        const AuthState(accion: AccionAuth.inicioSesion, estado: EstadoAccion.cargando),
        const AuthState(accion: AccionAuth.inicioSesion, estado: EstadoAccion.exito),
      ],
    );
  });

  blocTest<AuthBloc, AuthState>(
    'registro que pide confirmar el correo',
    setUp: () {
      when(() => repositorio.registrar(
            nombre: any(named: 'nombre'),
            correo: any(named: 'correo'),
            contrasena: any(named: 'contrasena'),
            universidadId: any(named: 'universidadId'),
          )).thenAnswer((_) async => ResultadoRegistro.confirmarCorreo);
    },
    build: () => AuthBloc(repositorio),
    act: (bloc) => bloc.add(const RegistroPedido(
      nombre: 'Ana Gómez',
      correo: 'ana@u.icesi.edu.co',
      contrasena: 'clave1234',
      universidad: _icesi,
    )),
    expect: () => [
      const AuthState(accion: AccionAuth.registro, estado: EstadoAccion.cargando),
      const AuthState(
        accion: AccionAuth.registro,
        estado: EstadoAccion.exito,
        resultadoRegistro: ResultadoRegistro.confirmarCorreo,
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'cerrar sesión deja el estado limpio',
    setUp: () => when(() => repositorio.cerrarSesion()).thenAnswer((_) async {}),
    build: () => AuthBloc(repositorio),
    seed: () => AuthState(sesion: Sesion.activa, perfil: _perfil),
    act: (bloc) => bloc.add(const CerrarSesionPedido()),
    expect: () => [
      AuthState(sesion: Sesion.activa, perfil: _perfil, accion: AccionAuth.cierreSesion, estado: EstadoAccion.cargando),
      const AuthState(sesion: Sesion.cerrada, accion: AccionAuth.cierreSesion, estado: EstadoAccion.exito),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'si Supabase avisa que la sesión venció, se cierra y olvida el perfil',
    setUp: () {
      when(() => repositorio.haySesion).thenReturn(true);
      when(() => repositorio.perfilActual()).thenAnswer((_) async => _perfil);
    },
    build: () => AuthBloc(repositorio),
    act: (bloc) async {
      bloc.add(const AuthIniciado());
      await Future<void>.delayed(Duration.zero);
      sesion.add(EventoSesion.cierre);
    },
    expect: () => [
      AuthState(sesion: Sesion.activa, perfil: _perfil),
      const AuthState(sesion: Sesion.cerrada),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'el enlace del correo de recuperación pide contraseña nueva',
    build: () => AuthBloc(repositorio),
    act: (bloc) async {
      bloc.add(const AuthIniciado());
      await Future<void>.delayed(Duration.zero);
      sesion.add(EventoSesion.recuperacion);
    },
    expect: () => [
      const AuthState(sesion: Sesion.cerrada),
      const AuthState(sesion: Sesion.recuperacion),
    ],
  );
}
