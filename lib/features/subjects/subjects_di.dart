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
/// - El repositorio va por su contrato (domain) y es uno solo para toda la app.
/// - Casos de uso y Cubits son `registerFactory`: uno nuevo por pantalla.
/// - Los que reciben algo de la ruta usan `registerFactoryParam`:
///   `sl<SubjectDetailCubit>(param1: materia)`.
void registrarSubjects(GetIt sl) {
  sl.registerLazySingleton<SubjectsRepository>(() => SubjectsRepositoryImpl(sl()));

  // Casos de uso (domain).
  sl.registerFactory(() => GuardarMateria(sl()));
  sl.registerFactory(() => ObtenerResumenSemestre(sl()));
  sl.registerFactory(() => TerminarConfiguracion(sl()));

  // Cubits (ui).
  sl.registerFactory(() => SubjectsCubit(sl()));
  sl.registerFactory(() => SetupSubjectsCubit(sl()));
  sl.registerFactory(() => SetupRemindersCubit(sl()));
  sl.registerFactory(() => NewSubjectCubit(sl()));
  sl.registerFactoryParam<SubjectDetailCubit, Materia?, void>(
    (materia, _) => SubjectDetailCubit(sl(), materia: materia),
  );
  sl.registerFactoryParam<RegisterGradeCubit, Materia?, Actividad?>(
    (materia, actividad) => RegisterGradeCubit(sl(), materia: materia, actividad: actividad),
  );
}
