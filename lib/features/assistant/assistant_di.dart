import 'package:get_it/get_it.dart';

import 'package:studyflow/features/assistant/data/assistant_repository_impl.dart';
import 'package:studyflow/features/assistant/domain/assistant_repository.dart';
import 'package:studyflow/features/assistant/domain/usecases/agregar_al_plan.dart';
import 'package:studyflow/features/assistant/domain/usecases/enviar_pregunta.dart';
import 'package:studyflow/features/assistant/ui/bloc/assistant_bloc.dart';

/// Dependencias de assistant (Santiago). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// - El repositorio va por su contrato (domain) y es uno solo para la app.
/// - Los casos de uso y el Bloc son `registerFactory`: uno nuevo cada vez que
///   se abre el chat (al cerrarlo, el Bloc se cierra con él).
/// - El Bloc también usa [SubscriptionRepository] (para saber si es Plus),
///   que registra subscription_di.dart.
void registrarAssistant(GetIt sl) {
  sl.registerLazySingleton<AssistantRepository>(
    () => AssistantRepositoryImpl(sl()),
  );

  // Casos de uso (domain).
  sl.registerFactory(() => EnviarPregunta(sl()));
  sl.registerFactory(() => AgregarAlPlan(sl()));

  // Bloc (ui).
  sl.registerFactory(
    () => AssistantBloc(sl(), sl(), enviar: sl(), agregar: sl()),
  );
}
