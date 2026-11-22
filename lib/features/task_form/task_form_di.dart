import 'package:get_it/get_it.dart';

import 'package:studyflow/features/task_form/data/task_form_repository_impl.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';

/// Dependencias de task_form (Camilo). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// El repositorio se registra por su contrato (domain): las pantallas y los
/// Blocs piden `sl<TaskFormRepository>()` y no saben que por debajo está Supabase.
/// Aquí también van los casos de uso y los Blocs/Cubits de esta parte:
///   sl.registerFactory(() => MiCubit(sl()));
void registrarTaskForm(GetIt sl) {
  sl.registerLazySingleton<TaskFormRepository>(() => TaskFormRepositoryImpl(sl()));
}
