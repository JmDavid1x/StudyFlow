import 'package:get_it/get_it.dart';

import 'package:studyflow/features/tasks/data/tasks_repository_impl.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';

/// Dependencias de tasks (Alejandro). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// El repositorio se registra por su contrato (domain): las pantallas y los
/// Blocs piden `sl<TasksRepository>()` y no saben que por debajo está Supabase.
/// Aquí también van los casos de uso y los Blocs/Cubits de esta parte:
///   sl.registerFactory(() => MiCubit(sl()));
void registrarTasks(GetIt sl) {
  sl.registerLazySingleton<TasksRepository>(() => TasksRepositoryImpl(sl()));
}
