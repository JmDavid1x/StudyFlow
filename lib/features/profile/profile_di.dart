import 'package:get_it/get_it.dart';

import 'package:studyflow/features/profile/data/profile_repository_impl.dart';
import 'package:studyflow/features/profile/domain/profile_repository.dart';

/// Dependencias de profile (Santiago). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// El repositorio se registra por su contrato (domain): las pantallas y los
/// Blocs piden `sl<ProfileRepository>()` y no saben que por debajo está Supabase.
/// Aquí también van los casos de uso y los Blocs/Cubits de esta parte:
///   sl.registerFactory(() => MiCubit(sl()));
void registrarProfile(GetIt sl) {
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));
}
