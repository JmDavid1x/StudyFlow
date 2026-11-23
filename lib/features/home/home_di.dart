import 'package:get_it/get_it.dart';

import 'package:studyflow/features/home/data/home_repository_impl.dart';
import 'package:studyflow/features/home/domain/home_repository.dart';
import 'package:studyflow/features/home/ui/bloc/home_cubit.dart';
import 'package:studyflow/features/home/ui/bloc/notifications_cubit.dart';

/// Dependencias de home (Alejandro). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// El repositorio va por su contrato (domain): las pantallas y los Cubits
/// piden `sl<HomeRepository>()` y no saben que por debajo está Supabase.
/// Los Cubits también usan `TasksRepository` y los casos de uso de completar
/// y presentar, que registra `registrarTasks` (GetIt los resuelve al pedirlos,
/// así que el orden de registro no importa).
void registrarHome(GetIt sl) {
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));

  sl.registerFactory(() => HomeCubit(sl(), sl(), completar: sl(), presentar: sl()));
  sl.registerFactory(() => NotificationsCubit(sl(), sl()));
}
