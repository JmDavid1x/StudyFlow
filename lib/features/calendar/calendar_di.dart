import 'package:get_it/get_it.dart';

import 'package:studyflow/features/calendar/data/calendar_repository_impl.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_bloc.dart';

/// Dependencias de calendar (Camilo). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// - El repositorio va por su contrato (domain) y es uno solo para la app.
/// - El CalendarBloc es `registerFactory`: uno nuevo cada vez que se abre la
///   pestaña. Usa también el repositorio de bloques y el caso de uso
///   CompletarBloque, que registra study_blocks_di.dart.
void registrarCalendar(GetIt sl) {
  sl.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(sl()),
  );

  // Bloc (ui): lo pide calendar_screen.dart con sl<CalendarBloc>().
  sl.registerFactory(() => CalendarBloc(sl(), sl(), completar: sl()));
}
