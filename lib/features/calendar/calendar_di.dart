import 'package:get_it/get_it.dart';

import 'package:studyflow/features/calendar/data/calendar_repository_impl.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';

/// Dependencias de calendar (Camilo). Las llama `configurarDependencias()`
/// (lib/core/di/inyeccion.dart) al arrancar la app.
///
/// El repositorio se registra por su contrato (domain): las pantallas y los
/// Blocs piden `sl<CalendarRepository>()` y no saben que por debajo está Supabase.
/// Aquí también van los casos de uso y los Blocs/Cubits de esta parte:
///   sl.registerFactory(() => MiCubit(sl()));
void registrarCalendar(GetIt sl) {
  sl.registerLazySingleton<CalendarRepository>(() => CalendarRepositoryImpl(sl()));
}
