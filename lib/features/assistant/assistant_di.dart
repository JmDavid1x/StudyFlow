import 'package:get_it/get_it.dart';

import 'package:studyflow/features/assistant/data/assistant_repository_impl.dart';
import 'package:studyflow/features/assistant/domain/assistant_repository.dart';

/// Dependencias de assistant (Santiago). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// El repositorio se registra por su contrato (domain): las pantallas y los
/// Blocs piden `sl<AssistantRepository>()` y no saben que por debajo está Supabase.
/// Aquí también van los casos de uso y los Blocs/Cubits de esta parte:
///   sl.registerFactory(() => MiCubit(sl()));
void registrarAssistant(GetIt sl) {
  sl.registerLazySingleton<AssistantRepository>(() => AssistantRepositoryImpl(sl()));
}
