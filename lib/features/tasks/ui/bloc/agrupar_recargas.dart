import 'dart:async';

/// Junta varios avisos seguidos en una sola recarga.
///
/// Realtime avisa una vez por fila: completar una tarea cambia la actividad y
/// sus bloques, y llegan varios avisos casi juntos. Sin esto la pantalla se
/// recargaría varias veces seguidas.
class AgruparRecargas {
  AgruparRecargas({this.espera = const Duration(milliseconds: 400)});

  final Duration espera;
  Timer? _timer;

  /// Programa [recargar]; si llega otro aviso antes de [espera], vuelve a empezar.
  void call(void Function() recargar) {
    _timer?.cancel();
    _timer = Timer(espera, recargar);
  }

  void cancelar() => _timer?.cancel();
}
