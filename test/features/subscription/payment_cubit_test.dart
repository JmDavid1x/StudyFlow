import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subscription/domain/planes_plus.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';
import 'package:studyflow/features/subscription/ui/bloc/payment_cubit.dart';

import '../assistant/fixtures.dart';

class _MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

void main() {
  late _MockSubscriptionRepository repo;

  PaymentCubit crear() =>
      PaymentCubit(repo, periodicidad: Periodicidad.semestral);

  setUp(() {
    repo = _MockSubscriptionRepository();
    when(() => repo.suscripcionVigente()).thenAnswer((_) async => null);
    when(
      () => repo.iniciarPrueba(Periodicidad.semestral, MetodoPago.nequi),
    ).thenAnswer((_) async => suscripcion());
  });

  blocTest<PaymentCubit, PaymentState>(
    'inicia la prueba con el plan y el método elegidos',
    build: crear,
    act: (cubit) async {
      cubit.elegirMetodo(MetodoPago.nequi);
      await cubit.iniciarPrueba();
    },
    skip: 1,
    expect: () => [
      isA<PaymentState>().having((s) => s.estado, 'estado', EtapaPago.enviando),
      isA<PaymentState>()
          .having((s) => s.estado, 'estado', EtapaPago.activada)
          .having(
            (s) => s.suscripcion?.estado,
            'suscripción',
            EstadoSuscripcion.enPrueba,
          ),
    ],
    verify: (_) => verify(
      () => repo.iniciarPrueba(Periodicidad.semestral, MetodoPago.nequi),
    ).called(1),
  );

  blocTest<PaymentCubit, PaymentState>(
    'si ya usó la prueba muestra el mensaje y deja intentar con otro plan',
    setUp: () => when(
      () => repo.iniciarPrueba(any(), any()),
    ).thenThrow(const AppException(mensajePruebaUsada)),
    build: crear,
    act: (cubit) => cubit.iniciarPrueba(),
    skip: 1,
    expect: () => [
      isA<PaymentState>()
          .having((s) => s.estado, 'estado', EtapaPago.eligiendo)
          .having((s) => s.error, 'error', 'Ya usaste tu prueba gratis.')
          .having((s) => s.errorId, 'errorId', 1),
    ],
  );

  blocTest<PaymentCubit, PaymentState>(
    'si ya es Plus no pide otra prueba',
    setUp: () => when(
      () => repo.suscripcionVigente(),
    ).thenAnswer((_) async => suscripcion()),
    build: crear,
    act: (cubit) => cubit.iniciarPrueba(),
    skip: 1,
    expect: () => [
      isA<PaymentState>().having(
        (s) => s.error,
        'error',
        'Ya tienes StudyFlow Plus.',
      ),
    ],
    verify: (_) => verifyNever(() => repo.iniciarPrueba(any(), any())),
  );

  setUpAll(() {
    registerFallbackValue(Periodicidad.mensual);
    registerFallbackValue(MetodoPago.tarjeta);
  });
}
