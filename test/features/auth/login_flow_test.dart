import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/auth/ui/bloc/auth_bloc.dart';
import 'package:studyflow/features/auth/ui/screens/login_screen.dart';

class _AuthBlocFalso extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

/// Simula a un estudiante usando la pantalla de inicio de sesión: toca,
/// escribe y espera lo mismo que vería en el celular. El AuthBloc es falso,
/// así la prueba no depende de internet ni de Supabase.
void main() {
  late _AuthBlocFalso bloc;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const AuthIniciado());
  });

  setUp(() {
    bloc = _AuthBlocFalso();
    when(() => bloc.state).thenReturn(const AuthState(sesion: Sesion.cerrada));
  });

  Future<void> abrirLogin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: bloc,
        child: MaterialApp(
          home: const LoginScreen(),
          routes: {
            AppRoutes.main: (_) => const Scaffold(body: Text('Pantalla de Inicio')),
            AppRoutes.setupSubjects: (_) => const Scaffold(body: Text('Configura tus materias')),
          },
        ),
      ),
    );
  }

  testWidgets('si toca Entrar sin escribir, ve los errores y no se llama a Supabase', (tester) async {
    await abrirLogin(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Escribe tu correo'), findsOneWidget);
    expect(find.text('Escribe tu contraseña'), findsOneWidget);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('escribe sus datos, entra y llega a Inicio', (tester) async {
    final estados = StreamController<AuthState>();
    addTearDown(estados.close);
    whenListen(bloc, estados.stream, initialState: const AuthState(sesion: Sesion.cerrada));
    await abrirLogin(tester);

    await tester.enterText(find.byType(TextField).at(0), 'ana@u.icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(1), 'clave1234');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    verify(() => bloc.add(const InicioSesionPedido(correo: 'ana@u.icesi.edu.co', contrasena: 'clave1234'))).called(1);

    // Lo que respondería Supabase: cargando y luego éxito.
    estados.add(const AuthState(sesion: Sesion.cerrada, accion: AccionAuth.inicioSesion, estado: EstadoAccion.cargando));
    await tester.pump();
    estados.add(AuthState(
      sesion: Sesion.activa,
      accion: AccionAuth.inicioSesion,
      estado: EstadoAccion.exito,
      perfil: Perfil(
        id: 'u1',
        universidadId: 'icesi',
        nombre: 'Ana',
        correo: 'ana@u.icesi.edu.co',
        configuracionCompleta: true,
        creadoEn: DateTime(2026, 11, 1),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Pantalla de Inicio'), findsOneWidget);
  });
}
