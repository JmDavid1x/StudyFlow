import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/realtime/cambios_en_vivo.dart';

/// [CambiosEnVivo] con Supabase Realtime (postgres_changes).
///
/// Las tablas tienen que estar en la publicación `supabase_realtime`
/// (migración `…_realtime.sql`). Realtime respeta el RLS: cada usuario solo
/// recibe los cambios de sus propias filas.
class CambiosEnVivoSupabase implements CambiosEnVivo {
  CambiosEnVivoSupabase(this._db);

  final SupabaseClient _db;
  static int _siguiente = 0;

  @override
  Stream<void> de(Set<String> tablas) {
    late StreamController<void> avisos;
    RealtimeChannel? canal;

    avisos = StreamController<void>(
      onListen: () {
        // Un canal por pantalla, con nombre único para no mezclar suscripciones.
        canal = _db.channel('cambios-${_siguiente++}');
        for (final tabla in tablas) {
          canal!.onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: tabla,
            callback: (_) => avisos.add(null),
          );
        }
        canal!.subscribe();
      },
      onCancel: () async {
        final abierto = canal;
        if (abierto != null) await _db.removeChannel(abierto);
      },
    );
    return agruparRafagas(avisos.stream);
  }
}
