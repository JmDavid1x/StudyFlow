import 'package:get_it/get_it.dart';

import 'package:studyflow/features/task_form/data/task_form_repository_impl.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';
import 'package:studyflow/features/task_form/domain/usecases/guardar_actividad.dart';
import 'package:studyflow/features/task_form/ui/bloc/task_form_cubit.dart';

/// Dependencias de task_form (Camilo). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// - El repositorio se registra por su contrato (domain) y es uno solo para
///   toda la app: las pantallas no saben que por debajo está Supabase.
/// - El caso de uso y el Cubit son `registerFactory`: uno nuevo cada vez que
///   se abre Nueva tarea o Editar tarea (al cerrarla, el Cubit se cierra).
void registrarTaskForm(GetIt sl) {
  sl.registerLazySingleton<TaskFormRepository>(
    () => TaskFormRepositoryImpl(sl()),
  );

  // Caso de uso (domain).
  sl.registerFactory(() => GuardarActividad(sl()));

  // Cubit (ui): lo pide task_form_routes.dart con sl<TaskFormCubit>().
  sl.registerFactory(() => TaskFormCubit(sl(), guardar: sl()));
}
