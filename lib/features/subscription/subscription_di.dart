import 'package:get_it/get_it.dart';

import 'package:studyflow/features/subscription/data/subscription_repository_impl.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';

/// Dependencias de subscription (Santiago). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// El repositorio se registra por su contrato (domain): las pantallas y los
/// Blocs piden `sl<SubscriptionRepository>()` y no saben que por debajo está Supabase.
/// Aquí también van los casos de uso y los Blocs/Cubits de esta parte:
///   sl.registerFactory(() => MiCubit(sl()));
void registrarSubscription(GetIt sl) {
  sl.registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepositoryImpl(sl()));
}
