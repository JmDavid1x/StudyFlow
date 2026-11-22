import 'package:get_it/get_it.dart';

import 'package:studyflow/features/subjects/data/subjects_repository_impl.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';

/// Dependencias de subjects (Miguel). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// El repositorio se registra por su contrato (domain): las pantallas y los
/// Blocs piden `sl<SubjectsRepository>()` y no saben que por debajo está Supabase.
/// Aquí también van los casos de uso y los Blocs/Cubits de esta parte:
///   sl.registerFactory(() => MiCubit(sl()));
void registrarSubjects(GetIt sl) {
  sl.registerLazySingleton<SubjectsRepository>(() => SubjectsRepositoryImpl(sl()));
}
