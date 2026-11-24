import 'package:get_it/get_it.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subjects/data/subjects_repository_impl.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';
import 'package:studyflow/features/subjects/domain/usecases/guardar_materia.dart';
import 'package:studyflow/features/subjects/domain/usecases/obtener_resumen_semestre.dart';
import 'package:studyflow/features/subjects/domain/usecases/terminar_configuracion.dart';
import 'package:studyflow/features/subjects/ui/bloc/new_subject_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/register_grade_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/setup_reminders_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/setup_subjects_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/subject_detail_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/subjects_cubit.dart';

/// Dependencias de subjects (Miguel). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// El repositorio se registra por su contrato (domain): las pantallas y los
/// Blocs piden `sl<SubjectsRepository>()` y no saben que por debajo está Supabase.
/// Los casos de uso no tienen estado (lazySingleton); los Cubits sí, así que
/// son factory: cada pantalla recibe uno nuevo y lo cierra al salir.
void registrarSubjects(GetIt sl) {
  // Repositorio
  sl.registerLazySingleton<SubjectsRepository>(() => SubjectsRepositoryImpl(sl()));

  // Casos de uso
  sl.registerLazySingleton<GuardarMateria>(() => GuardarMateria(sl()));
  sl.registerLazySingleton<ObtenerResumenSemestre>(() => ObtenerResumenSemestre(sl()));
  sl.registerLazySingleton<TerminarConfiguracion>(() => TerminarConfiguracion(sl()));

  // Cubits sin argumentos de ruta
  sl.registerFactory<SubjectsCubit>(() => SubjectsCubit(sl()));
  sl.registerFactory<SetupSubjectsCubit>(() => SetupSubjectsCubit(sl()));
  sl.registerFactory<SetupRemindersCubit>(() => SetupRemindersCubit(sl()));
  sl.registerFactory<NewSubjectCubit>(() => NewSubjectCubit(sl()));

  // Cubits que reciben algo de la ruta (pueden llegar sin argumento -> null)
  sl.registerFactoryParam<SubjectDetailCubit, Materia?, void>(
    (materia, _) => SubjectDetailCubit(sl(), materia: materia),
  );
  sl.registerFactoryParam<RegisterGradeCubit, Materia?, Actividad?>(
    (materia, actividad) =>
        RegisterGradeCubit(sl(), materia: materia, actividad: actividad),
  );
}