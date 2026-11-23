import 'package:get_it/get_it.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/study_blocks/data/study_blocks_repository_impl.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/completar_bloque.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/crear_bloque.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/descartar_bloque.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/reprogramar_bloque.dart';
import 'package:studyflow/features/study_blocks/ui/bloc/new_study_block_cubit.dart';
import 'package:studyflow/features/study_blocks/ui/bloc/study_block_cubit.dart';

/// Dependencias de study_blocks (Camilo). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// - El repositorio va por su contrato (domain) y es uno solo para la app.
/// - Los casos de uso y los Cubits son `registerFactory`: nuevos cada vez.
/// - Bloque de estudio (27) recibe el bloque de la ruta: `registerFactoryParam`,
///   y la pantalla hace `sl<StudyBlockCubit>(param1: bloque)`.
///
/// CompletarBloque también lo usa el CalendarBloc (el circulito del calendario).
void registrarStudyBlocks(GetIt sl) {
  sl.registerLazySingleton<StudyBlocksRepository>(
    () => StudyBlocksRepositoryImpl(sl()),
  );

  // Casos de uso (domain). Crear y reprogramar revisan cruces con el calendario.
  sl.registerFactory(() => CrearBloque(sl(), sl()));
  sl.registerFactory(() => ReprogramarBloque(sl(), sl()));
  sl.registerFactory(() => CompletarBloque(sl()));
  sl.registerFactory(() => DescartarBloque(sl()));

  // Cubits (ui).
  sl.registerFactory(
    () => NewStudyBlockCubit(sl(), sl(), crear: sl(), reprogramar: sl()),
  );
  sl.registerFactoryParam<StudyBlockCubit, BloqueEstudio, void>(
    (bloque, _) =>
        StudyBlockCubit(sl(), bloque, completar: sl(), descartar: sl()),
  );
}
