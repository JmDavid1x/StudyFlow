import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/errors/app_exception.dart';

/// Atajo al cliente de Supabase ya inicializado en main.dart.
///
/// Las pantallas NO crean repositorios con este cliente: los piden a GetIt
/// (`lib/core/di/inyeccion.dart`), que ya sabe qué implementación usar:
///   `BlocProvider(create: (_) => TasksBloc(sl<TasksRepository>()))`
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
