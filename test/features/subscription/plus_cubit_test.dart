import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/profile/domain/profile_repository.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';
import 'package:studyflow/features/subscription/ui/bloc/plus_cubit.dart';

import '../assistant/fixtures.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

void main() {
  late _MockProfileRepository perfiles;
  late _MockSubscriptionRepository suscripciones;
  final ahora = DateTime(2026, 11, 10, 10);

  PlusCubit crear() => PlusCubit(perfiles, suscripciones, reloj: () => ahora);

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() {
    perfiles = _MockProfileRepository();
    suscripciones = _MockSubscriptionRepository();
    when(
      () => perfiles.consultasUsadasEstaSemana(any()),
    ).thenAnswer((_) async => 4);
    when(
      () => suscripciones.suscripcionVigente(),
    ).thenAnswer((_) async => null);
  });

  blocTest<PlusCubit, PlusState>(
    'en el plan gratis muestra las consultas usadas',
    build: crear,
    act: (cubit) => cubit.cargar(),
    skip: 1,
    expect: () => [
      isA<PlusState>()
          .having((s) => s.estado, 'estado', EstadoPlus.listo)
          .having((s) => s.esPlus, 'plus', isFalse)
          .having((s) => s.limite.etiqueta, 'contador', '4 de 5 gratis'),
    ],
  );

  blocTest<PlusCubit, PlusState>(
    'si ya tiene la prueba, es Plus',
    setUp: () => when(
      () => suscripciones.suscripcionVigente(),
    ).thenAnswer((_) async => suscripcion()),
    build: crear,
    act: (cubit) => cubit.cargar(),
    skip: 1,
    expect: () => [isA<PlusState>().having((s) => s.esPlus, 'plus', isTrue)],
  );

  blocTest<PlusCubit, PlusState>(
    'elige semestre',
    build: crear,
    act: (cubit) => cubit.elegir(Periodicidad.semestral),
    expect: () => [
      isA<PlusState>().having(
        (s) => s.periodicidad,
        'periodicidad',
        Periodicidad.semestral,
      ),
    ],
  );

  blocTest<PlusCubit, PlusState>(
    'si no puede cargar queda en error',
    setUp: () => when(
      () => suscripciones.suscripcionVigente(),
    ).thenThrow(const AppException('Sin conexión.')),
    build: crear,
    act: (cubit) => cubit.cargar(),
    skip: 1,
    expect: () => [
      isA<PlusState>()
          .having((s) => s.estado, 'estado', EstadoPlus.error)
          .having((s) => s.mensaje, 'mensaje', 'Sin conexión.'),
    ],
  );
}
