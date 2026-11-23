import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/core/realtime/cambios_en_vivo.dart';
import 'package:studyflow/core/realtime/recargar_en_vivo.dart';

/// Cambios en vivo falsos: el test decide cuándo "cambió algo en Supabase".
class _CambiosFalsos implements CambiosEnVivo {
  final avisos = StreamController<void>.broadcast();
  Set<String>? tablasPedidas;

  @override
  Stream<void> de(Set<String> tablas) {
    tablasPedidas = tablas;
    return avisos.stream;
  }
}

void main() {
  late _CambiosFalsos cambios;

  setUp(() async {
    await sl.reset();
    cambios = _CambiosFalsos();
    // Igual que en la app, RecargarEnVivo lo pide a GetIt.
    sl.registerSingleton<CambiosEnVivo>(cambios);
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget pantalla(VoidCallback alCambiar) => Directionality(
        textDirection: TextDirection.ltr,
        child: RecargarEnVivo(
          tablas: const {'actividades', 'calificaciones'},
          alCambiar: alCambiar,
          child: const Text('Inicio'),
        ),
      );

  testWidgets('se suscribe a sus tablas y recarga cuando llega un cambio', (tester) async {
    var recargas = 0;
    await tester.pumpWidget(pantalla(() => recargas++));

    expect(find.text('Inicio'), findsOneWidget);
    expect(cambios.tablasPedidas, {'actividades', 'calificaciones'});

    cambios.avisos.add(null);
    await tester.pump();
    expect(recargas, 1);
  });

  testWidgets('al salir de la pantalla cierra la suscripción', (tester) async {
    var recargas = 0;
    await tester.pumpWidget(pantalla(() => recargas++));
    expect(cambios.avisos.hasListener, isTrue);

    await tester.pumpWidget(const SizedBox());
    expect(cambios.avisos.hasListener, isFalse);

    cambios.avisos.add(null);
    await tester.pump();
    expect(recargas, 0);
  });

  testWidgets('si Realtime falla, la pantalla sigue funcionando', (tester) async {
    await tester.pumpWidget(pantalla(() {}));
    cambios.avisos.addError(Exception('sin conexión en vivo'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Inicio'), findsOneWidget);
  });
}
