import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/features/assistant/assistant_di.dart';
import 'package:studyflow/features/assistant/domain/assistant_repository.dart';
import 'package:studyflow/features/assistant/domain/usecases/enviar_pregunta.dart';
import 'package:studyflow/features/assistant/ui/bloc/assistant_bloc.dart';
import 'package:studyflow/features/profile/domain/profile_repository.dart';
import 'package:studyflow/features/profile/profile_di.dart';
import 'package:studyflow/features/profile/ui/bloc/notification_settings_cubit.dart';
import 'package:studyflow/features/profile/ui/bloc/profile_cubit.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';
import 'package:studyflow/features/subscription/subscription_di.dart';
import 'package:studyflow/features/subscription/ui/bloc/payment_cubit.dart';
import 'package:studyflow/features/subscription/ui/bloc/plus_cubit.dart';

import 'fixtures.dart';

class _FalsoAssistantRepository extends Mock implements AssistantRepository {}

class _FalsoProfileRepository extends Mock implements ProfileRepository {}

class _FalsoSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

/// GetIt de Asistente, Perfil y Plus: se registran las partes reales y se
/// cambian los repositorios por falsos. Así se prueba que los Blocs y Cubits
/// que entrega `sl` usan lo registrado y no crean Supabase por su cuenta.
void main() {
  late _FalsoAssistantRepository asistente;
  late _FalsoProfileRepository perfiles;
  late _FalsoSubscriptionRepository suscripciones;

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() async {
    await sl.reset();
    registrarAssistant(sl);
    registrarProfile(sl);
    registrarSubscription(sl);

    asistente = _FalsoAssistantRepository();
    perfiles = _FalsoProfileRepository();
    suscripciones = _FalsoSubscriptionRepository();
    await sl.unregister<AssistantRepository>();
    await sl.unregister<ProfileRepository>();
    await sl.unregister<SubscriptionRepository>();
    sl.registerSingleton<AssistantRepository>(asistente);
    sl.registerSingleton<ProfileRepository>(perfiles);
    sl.registerSingleton<SubscriptionRepository>(suscripciones);

    when(
      () => asistente.historial(),
    ).thenAnswer((_) async => [mensaje('m1', creadoEn: DateTime.now())]);
    when(
      () => suscripciones.suscripcionVigente(),
    ).thenAnswer((_) async => null);
    when(() => perfiles.perfil()).thenAnswer(
      (_) async => Perfil(
        id: 'p1',
        universidadId: null,
        nombre: 'Santiago',
        correo: 's@gmail.com',
        configuracionCompleta: true,
        creadoEn: DateTime(2026, 11, 1),
      ),
    );
    when(() => perfiles.periodoActivo()).thenAnswer((_) async => null);
    when(
      () => perfiles.consultasUsadasEstaSemana(any()),
    ).thenAnswer((_) async => 2);
  });

  tearDown(() => sl.reset());

  test(
    'AssistantBloc sale de GetIt y carga el chat con el repositorio registrado',
    () async {
      final bloc = sl<AssistantBloc>()..add(const AsistenteIniciado());
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AssistantState>()
              .having((s) => s.estado, 'estado', EstadoAsistente.listo)
              .having((s) => s.mensajes.length, 'mensajes', 1),
        ),
      );
      verify(() => asistente.historial()).called(1);
      await bloc.close();
    },
  );

  test('ProfileCubit carga con los repositorios registrados', () async {
    final cubit = sl<ProfileCubit>();
    await cubit.cargar();
    expect(cubit.state.estado, EstadoPerfil.listo);
    expect(cubit.state.resumen!.limite.usadas, 2);
    verify(() => perfiles.perfil()).called(1);
    verify(() => suscripciones.suscripcionVigente()).called(1);
    await cubit.close();
  });

  test(
    'PaymentCubit recibe la periodicidad de la ruta (registerFactoryParam)',
    () async {
      final cubit = sl<PaymentCubit>(param1: Periodicidad.semestral);
      expect(cubit.state.periodicidad, Periodicidad.semestral);
      await cubit.close();
    },
  );

  test(
    'los Blocs y casos de uso son nuevos cada vez; el repositorio es uno solo',
    () async {
      final a = sl<PlusCubit>();
      final b = sl<PlusCubit>();
      expect(a, isNot(same(b)));
      expect(sl<EnviarPregunta>(), isNot(same(sl<EnviarPregunta>())));
      expect(sl<ProfileRepository>(), same(perfiles));
      expect(sl<NotificationSettingsCubit>(), isA<NotificationSettingsCubit>());
      await a.close();
      await b.close();
    },
  );
}
