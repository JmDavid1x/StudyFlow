/// Cambios en vivo (Sprint 3), en Dart puro: las pantallas no dependen de
/// Supabase, solo de este contrato. La implementación con Supabase Realtime
/// está en `cambios_en_vivo_supabase.dart`.
library;

import 'dart:async';

/// Avisa cuando cambia algo en las tablas que mira una pantalla (por ejemplo,
/// si el estudiante completa una tarea desde otro celular o desde la web).
abstract class CambiosEnVivo {
  /// Un evento por cada ráfaga de cambios en [tablas]. Al cancelar la
  /// suscripción se cierra la conexión.
  Stream<void> de(Set<String> tablas);
}

/// Junta varios avisos seguidos en uno solo: si se guardan cinco filas a la
/// vez, la pantalla recarga una vez y no cinco. Emite [espera] después del
/// último aviso de la ráfaga.
Stream<void> agruparRafagas(
  Stream<void> avisos, {
  Duration espera = const Duration(milliseconds: 400),
}) {
  late StreamController<void> salida;
  StreamSubscription<void>? entrada;
  Timer? temporizador;

  salida = StreamController<void>(
    onListen: () {
      entrada = avisos.listen(
        (_) {
          temporizador?.cancel();
          temporizador = Timer(espera, () => salida.add(null));
        },
        onError: salida.addError,
        onDone: () {
          temporizador?.cancel();
          salida.close();
        },
      );
    },
    onCancel: () async {
      temporizador?.cancel();
      await entrada?.cancel();
    },
  );
  return salida.stream;
}
