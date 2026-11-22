import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/realtime/cambios_en_vivo.dart';
import 'package:studyflow/core/realtime/cambios_en_vivo_supabase.dart';
import 'package:studyflow/features/assistant/assistant_di.dart';
import 'package:studyflow/features/auth/auth_di.dart';
import 'package:studyflow/features/calendar/calendar_di.dart';
import 'package:studyflow/features/home/home_di.dart';
import 'package:studyflow/features/profile/profile_di.dart';
import 'package:studyflow/features/study_blocks/study_blocks_di.dart';
import 'package:studyflow/features/subjects/subjects_di.dart';
import 'package:studyflow/features/subscription/subscription_di.dart';
import 'package:studyflow/features/task_form/task_form_di.dart';
import 'package:studyflow/features/tasks/tasks_di.dart';

/// Contenedor de dependencias de toda la app (GetIt).
///
/// En vez de que cada pantalla haga `TasksRepositoryImpl(supabase)`, la app
/// registra aquí UNA vez qué implementación va detrás de cada contrato, y las
/// pantallas piden `sl<TasksRepository>()`. Así:
/// - la UI y los Blocs dependen de la abstracción (domain), no de Supabase;
/// - cambiar Supabase por otra cosa, o por un falso en los tests, es cambiar
///   una línea aquí y no 20 pantallas.
final GetIt sl = GetIt.instance;

/// Se llama en main.dart después de `Supabase.initialize`. En los tests se le
/// pasa un [cliente] propio.
void configurarDependencias({SupabaseClient? cliente}) {
  // Externos: el cliente de Supabase y los cambios en vivo.
  sl.registerLazySingleton<SupabaseClient>(() => cliente ?? Supabase.instance.client);
  sl.registerLazySingleton<CambiosEnVivo>(() => CambiosEnVivoSupabase(sl()));

  // Cada parte registra lo suyo en su carpeta (lib/features/<parte>/<parte>_di.dart).
  registrarAuth(sl);
  registrarHome(sl);
  registrarTasks(sl);
  registrarTaskForm(sl);
  registrarCalendar(sl);
  registrarStudyBlocks(sl);
  registrarSubjects(sl);
  registrarAssistant(sl);
  registrarProfile(sl);
  registrarSubscription(sl);
}
