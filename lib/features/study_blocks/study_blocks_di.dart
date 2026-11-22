import 'package:get_it/get_it.dart';

import 'package:studyflow/features/study_blocks/data/study_blocks_repository_impl.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';

/// Dependencias de study_blocks (Camilo). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// El repositorio se registra por su contrato (domain): las pantallas y los
/// Blocs piden `sl<StudyBlocksRepository>()` y no saben que por debajo está Supabase.
/// Aquí también van los casos de uso y los Blocs/Cubits de esta parte:
///   sl.registerFactory(() => MiCubit(sl()));
void registrarStudyBlocks(GetIt sl) {
  sl.registerLazySingleton<StudyBlocksRepository>(() => StudyBlocksRepositoryImpl(sl()));
}
