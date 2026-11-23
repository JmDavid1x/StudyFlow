import 'package:get_it/get_it.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/tasks/data/tasks_repository_impl.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';
import 'package:studyflow/features/tasks/domain/usecases/completar_actividad.dart';
import 'package:studyflow/features/tasks/domain/usecases/eliminar_actividad.dart';
import 'package:studyflow/features/tasks/domain/usecases/marcar_no_entregada.dart';
import 'package:studyflow/features/tasks/domain/usecases/marcar_presentado.dart';
import 'package:studyflow/features/tasks/ui/bloc/task_detail_cubit.dart';
import 'package:studyflow/features/tasks/ui/bloc/tasks_bloc.dart';

/// Dependencias de tasks (Alejandro). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// - El repositorio va por su contrato (domain) y es uno solo para toda la app.
/// - Los casos de uso y los Blocs son `registerFactory`: uno nuevo cada vez que
///   se abre la pantalla (al cerrarla, el Bloc se cierra con ella).
/// - El detalle recibe la Actividad de la ruta: `registerFactoryParam`, y la
///   pantalla hace `sl<TaskDetailCubit>(param1: actividad)`.
///
/// Home también usa [TasksRepository], [CompletarActividad] y [MarcarPresentado]
/// (el círculo de Inicio): los pide aquí mismo a GetIt.
void registrarTasks(GetIt sl) {
  sl.registerLazySingleton<TasksRepository>(() => TasksRepositoryImpl(sl()));

  // Casos de uso (domain).
  sl.registerFactory(() => CompletarActividad(sl()));
  sl.registerFactory(() => MarcarPresentado(sl()));
  sl.registerFactory(() => MarcarNoEntregada(sl()));
  sl.registerFactory(() => EliminarActividad(sl()));

  // Blocs y Cubits (ui).
  sl.registerFactory(() => TasksBloc(sl(), completar: sl(), presentar: sl()));
  sl.registerFactoryParam<TaskDetailCubit, Actividad, void>(
    (actividad, _) =>
        TaskDetailCubit(sl(), actividad, completar: sl(), noEntregada: sl(), presentar: sl(), eliminar: sl()),
  );
}
