import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/profile/domain/profile_repository.dart';
import 'package:studyflow/features/profile/ui/bloc/profile_cubit.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';

import '../assistant/fixtures.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

void main() {
  late _MockProfileRepository perfiles;
  late _MockSubscriptionRepository suscripciones;
  final ahora = DateTime(2026, 11, 10, 10);
  final perfil = Perfil(
    id: 'p1',
    universidadId: 'u1',
    nombre: 'Santiago Mosquera',
    correo: 's@u.icesi.edu.co',
    configuracionCompleta: true,
    creadoEn: DateTime(2026, 11, 1),
  );

  ProfileCubit crear() =>
      ProfileCubit(perfiles, suscripciones, reloj: () => ahora);

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() {
    perfiles = _MockProfileRepository();
    suscripciones = _MockSubscriptionRepository();
    when(() => perfiles.perfil()).thenAnswer((_) async => perfil);
    when(() => perfiles.periodoActivo()).thenAnswer((_) async => null);
    when(
      () => perfiles.consultasUsadasEstaSemana(any()),
    ).thenAnswer((_) async => 3);
    when(
      () => suscripciones.suscripcionVigente(),
    ).thenAnswer((_) async => null);
  });

  blocTest<ProfileCubit, ProfileState>(
    'carga el perfil con el plan gratis y las consultas de la semana',
    build: crear,
    act: (cubit) => cubit.cargar(),
    expect: () => [
      isA<ProfileState>().having(
        (s) => s.estado,
        'estado',
        EstadoPerfil.cargando,
      ),
      isA<ProfileState>()
          .having((s) => s.estado, 'estado', EstadoPerfil.listo)
          .having(
            (s) => s.resumen!.perfil.nombre,
            'nombre',
            'Santiago Mosquera',
          )
          .having((s) => s.resumen!.esPlus, 'plus', isFalse)
          .having((s) => s.resumen!.limite.usadas, 'usadas', 3),
    ],
    verify: (_) =>
        verify(() => perfiles.consultasUsadasEstaSemana(ahora)).called(1),
  );

  blocTest<ProfileCubit, ProfileState>(
    'con una suscripción en prueba es Plus',
    setUp: () => when(
      () => suscripciones.suscripcionVigente(),
    ).thenAnswer((_) async => suscripcion()),
    build: crear,
    act: (cubit) => cubit.cargar(),
    skip: 1,
    expect: () => [
      isA<ProfileState>()
          .having((s) => s.resumen!.esPlus, 'plus', isTrue)
          .having(
            (s) => s.resumen!.limite.puedeConsultarIA,
            'sin límite',
            isTrue,
          ),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'si falla la primera carga queda en error con el mensaje',
    setUp: () => when(
      () => perfiles.perfil(),
    ).thenThrow(const AppException('Sin conexión.')),
    build: crear,
    act: (cubit) => cubit.cargar(),
    expect: () => [
      isA<ProfileState>().having(
        (s) => s.estado,
        'estado',
        EstadoPerfil.cargando,
      ),
      isA<ProfileState>()
          .having((s) => s.estado, 'estado', EstadoPerfil.error)
          .having((s) => s.mensaje, 'mensaje', 'Sin conexión.'),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'si falla al recargar, se queda con lo de antes',
    build: crear,
    act: (cubit) async {
      await cubit.cargar();
      when(
        () => perfiles.perfil(),
      ).thenThrow(const AppException('Sin conexión.'));
      await cubit.cargar();
    },
    skip: 2,
    expect: () => <ProfileState>[],
  );
}
