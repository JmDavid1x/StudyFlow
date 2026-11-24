import 'package:get_it/get_it.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subscription/data/subscription_repository_impl.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';
import 'package:studyflow/features/subscription/domain/usecases/iniciar_prueba.dart';
import 'package:studyflow/features/subscription/ui/bloc/payment_cubit.dart';
import 'package:studyflow/features/subscription/ui/bloc/plus_cubit.dart';

/// Dependencias de subscription (Santiago). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// - El repositorio va por su contrato (domain) y es uno solo para la app.
/// - El caso de uso y los Cubits son `registerFactory`: uno nuevo por pantalla.
/// - El pago recibe la periodicidad elegida en Plus (argumento de la ruta):
///   `registerFactoryParam`, y la ruta hace `sl<PaymentCubit>(param1: periodicidad)`.
void registrarSubscription(GetIt sl) {
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(sl()),
  );

  // Caso de uso (domain).
  sl.registerFactory(() => IniciarPrueba(sl()));

  // Cubits (ui).
  sl.registerFactory(() => PlusCubit(sl(), sl()));
  sl.registerFactoryParam<PaymentCubit, Periodicidad, void>(
    (periodicidad, _) =>
        PaymentCubit(sl(), periodicidad: periodicidad, iniciar: sl()),
  );
}
