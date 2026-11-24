import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/core/realtime/cambios_en_vivo.dart';
import 'package:studyflow/features/assistant/domain/assistant_repository.dart';
import 'package:studyflow/features/assistant/ui/bloc/assistant_bloc.dart';
import 'package:studyflow/features/auth/domain/auth_repository.dart';
import 'package:studyflow/features/auth/ui/bloc/auth_bloc.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/home/domain/home_repository.dart';
import 'package:studyflow/features/profile/domain/profile_repository.dart';
import 'package:studyflow/features/profile/ui/bloc/notification_settings_cubit.dart';
import 'package:studyflow/features/profile/ui/bloc/profile_cubit.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';
import 'package:studyflow/features/subscription/ui/bloc/payment_cubit.dart';
import 'package:studyflow/features/subscription/ui/bloc/plus_cubit.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';

void main() {
  // Un cliente apuntando a ningún lado: aquí solo se prueba el armado, no la red.
  final cliente = SupabaseClient('http://localhost:54321', 'llave-de-prueba');

  setUp(() async {
    await sl.reset();
    configurarDependencias(cliente: cliente);
  });

  tearDown(() => sl.reset());

  test('cada contrato del domain tiene su implementación registrada', () {
    expect(sl<SupabaseClient>(), same(cliente));
    expect(sl<CambiosEnVivo>(), isA<CambiosEnVivo>());
    expect(sl<AuthRepository>(), isA<AuthRepository>());
    expect(sl<HomeRepository>(), isA<HomeRepository>());
    expect(sl<TasksRepository>(), isA<TasksRepository>());
    expect(sl<TaskFormRepository>(), isA<TaskFormRepository>());
    expect(sl<CalendarRepository>(), isA<CalendarRepository>());
    expect(sl<StudyBlocksRepository>(), isA<StudyBlocksRepository>());
    expect(sl<SubjectsRepository>(), isA<SubjectsRepository>());
    expect(sl<AssistantRepository>(), isA<AssistantRepository>());
    expect(sl<ProfileRepository>(), isA<ProfileRepository>());
    expect(sl<SubscriptionRepository>(), isA<SubscriptionRepository>());
  });

  test('los repositorios son únicos y el AuthBloc se crea nuevo cada vez', () async {
    expect(sl<TasksRepository>(), same(sl<TasksRepository>()));
    final a = sl<AuthBloc>();
    final b = sl<AuthBloc>();
    expect(a, isNot(same(b)));
    await a.close();
    await b.close();
  });

  test('GetIt arma los Blocs y Cubits de Asistente, Perfil y Plus', () async {
    final creados = <dynamic>[
      sl<AssistantBloc>(),
      sl<ProfileCubit>(),
      sl<NotificationSettingsCubit>(),
      sl<PlusCubit>(),
      sl<PaymentCubit>(param1: Periodicidad.semestral),
    ];
    expect(creados, hasLength(5));
    expect((creados.last as PaymentCubit).state.periodicidad, Periodicidad.semestral);
    for (final c in creados) {
      await c.close();
    }
  });
}
