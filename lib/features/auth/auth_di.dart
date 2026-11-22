import 'package:get_it/get_it.dart';

import 'package:studyflow/features/auth/data/auth_repository_impl.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';
import 'package:studyflow/features/auth/ui/bloc/auth_bloc.dart';

/// Dependencias de auth (Jose). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// El repositorio se registra por su contrato (domain): las pantallas y los
/// Blocs piden `sl<AuthRepository>()` y no saben que por debajo está Supabase.
/// Aquí también van los casos de uso y los Blocs/Cubits de esta parte:
///   sl.registerFactory(() => MiCubit(sl()));
void registrarAuth(GetIt sl) {
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  // El AuthBloc es uno solo para toda la app: lo crea app.dart una vez.
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
}
