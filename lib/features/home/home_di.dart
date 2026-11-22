import 'package:get_it/get_it.dart';

import 'package:studyflow/features/home/data/home_repository_impl.dart';
import 'package:studyflow/features/home/domain/home_repository.dart';

/// Dependencias de home (Alejandro). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// El repositorio se registra por su contrato (domain): las pantallas y los
/// Blocs piden `sl<HomeRepository>()` y no saben que por debajo está Supabase.
/// Aquí también van los casos de uso y los Blocs/Cubits de esta parte:
///   sl.registerFactory(() => MiCubit(sl()));
void registrarHome(GetIt sl) {
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
}
