import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/errors/app_exception.dart';

/// Atajo al cliente de Supabase ya inicializado en main.dart.
///
/// Los repositorios lo reciben por el constructor (así se pueden probar con
/// un cliente falso); en las rutas se pasa `supabase`:
///   BlocProvider(create: (_) => TasksBloc(TasksRepositoryImpl(supabase)))
SupabaseClient get supabase => Supabase.instance.client;

extension SesionActual on SupabaseClient {
  /// Id del usuario con sesión (= perfiles.id). Solo se usa después del login;
  /// si la sesión venció, lanza un error que la UI puede mostrar.
  String get usuarioId {
    final usuario = auth.currentUser;
    if (usuario == null) throw const AppException('Tu sesión venció. Inicia sesión de nuevo.');
    return usuario.id;
  }
}
