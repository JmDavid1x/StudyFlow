import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:studyflow/core/realtime/cambios_en_vivo.dart';

void main() {
  const espera = Duration(milliseconds: 50);

  test('una ráfaga de cambios se vuelve un solo aviso', () async {
    final avisos = StreamController<void>();
    var recargas = 0;
    final sub = agruparRafagas(avisos.stream, espera: espera).listen((_) => recargas++);

    for (var i = 0; i < 5; i++) {
      avisos.add(null);
    }
    await Future<void>.delayed(espera * 3);
    expect(recargas, 1);

    await sub.cancel();
    await avisos.close();
  });

  test('dos ráfagas separadas son dos avisos', () async {
    final avisos = StreamController<void>();
    var recargas = 0;
    final sub = agruparRafagas(avisos.stream, espera: espera).listen((_) => recargas++);

    avisos.add(null);
    await Future<void>.delayed(espera * 3);
    avisos.add(null);
    await Future<void>.delayed(espera * 3);
    expect(recargas, 2);

    await sub.cancel();
    await avisos.close();
  });

  test('al cancelar no llega ningún aviso pendiente', () async {
    final avisos = StreamController<void>();
    var recargas = 0;
    final sub = agruparRafagas(avisos.stream, espera: espera).listen((_) => recargas++);

    avisos.add(null);
    await sub.cancel();
    await Future<void>.delayed(espera * 3);
    expect(recargas, 0);

    await avisos.close();
  });
}
