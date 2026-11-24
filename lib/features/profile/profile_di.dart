import 'package:get_it/get_it.dart';

import 'package:studyflow/features/profile/data/profile_repository_impl.dart';
import 'package:studyflow/features/profile/domain/profile_repository.dart';
import 'package:studyflow/features/profile/domain/usecases/cargar_perfil.dart';
import 'package:studyflow/features/profile/ui/bloc/notification_settings_cubit.dart';
import 'package:studyflow/features/profile/ui/bloc/profile_cubit.dart';

/// Dependencias de profile (Santiago). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// - El repositorio va por su contrato (domain) y es uno solo para la app.
/// - El caso de uso y los Cubits son `registerFactory`: uno nuevo por pantalla.
/// - [CargarPerfil] y [ProfileCubit] también usan [SubscriptionRepository]
///   (plan actual), que registra subscription_di.dart.
void registrarProfile(GetIt sl) {
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // Caso de uso (domain).
  sl.registerFactory(() => CargarPerfil(sl(), sl()));

  // Cubits (ui).
  sl.registerFactory(() => ProfileCubit(sl(), sl(), cargar: sl()));
  sl.registerFactory(() => NotificationSettingsCubit(sl()));
}
