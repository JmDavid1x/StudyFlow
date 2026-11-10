import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/profile/domain/profile_repository.dart';
import 'package:studyflow/features/profile/ui/bloc/notification_settings_cubit.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

const _ajustes = AjustesNotificacion(
  perfilId: 'p1',
  pushActivas: true,
  recordatorioEntregas: true,
  diasAntes: 1,
  avisoMismoDia: true,
  horasAntes: 3,
  avisoBloques: true,
  minutosAntesBloque: 15,
  planDelDia: true,
  horaPlan: Hora(7, 0),
  resumenSemanal: true,
  diaResumen: 7,
  horaResumen: Hora(18, 0),
);

void main() {
  late _MockProfileRepository repositorio;

  setUpAll(() => registerFallbackValue(_ajustes));

  setUp(() {
    repositorio = _MockProfileRepository();
    when(() => repositorio.ajustes()).thenAnswer((_) async => _ajustes);
    when(() => repositorio.guardarAjustes(any())).thenAnswer((_) async {});
  });

  blocTest<NotificationSettingsCubit, NotificationSettingsState>(
    'carga los ajustes guardados',
    build: () => NotificationSettingsCubit(repositorio),
    act: (cubit) => cubit.cargar(),
    expect: () => [
      const NotificationSettingsState(),
      const NotificationSettingsState(
        estado: EstadoAjustes.listo,
        ajustes: _ajustes,
      ),
    ],
  );

  blocTest<NotificationSettingsCubit, NotificationSettingsState>(
    'guarda lo que cambió el usuario',
    build: () => NotificationSettingsCubit(repositorio),
    act: (cubit) async {
      await cubit.cargar();
      cubit.cambiar(
        _ajustes.copyWith(diasAntes: 3, horaPlan: const Hora(6, 30)),
      );
      await cubit.guardar();
    },
    skip: 3,
    expect: () => [
      isA<NotificationSettingsState>().having(
        (s) => s.estado,
        'estado',
        EstadoAjustes.guardando,
      ),
      isA<NotificationSettingsState>().having(
        (s) => s.estado,
        'estado',
        EstadoAjustes.guardado,
      ),
    ],
    verify: (_) => verify(
      () => repositorio.guardarAjustes(
        _ajustes.copyWith(diasAntes: 3, horaPlan: const Hora(6, 30)),
      ),
    ).called(1),
  );

  blocTest<NotificationSettingsCubit, NotificationSettingsState>(
    'si no puede guardar, avisa y deja seguir editando',
    setUp: () => when(
      () => repositorio.guardarAjustes(any()),
    ).thenThrow(const AppException('Sin conexión.')),
    build: () => NotificationSettingsCubit(repositorio),
    act: (cubit) async {
      await cubit.cargar();
      await cubit.guardar();
    },
    skip: 3,
    expect: () => [
      isA<NotificationSettingsState>()
          .having((s) => s.estado, 'estado', EstadoAjustes.listo)
          .having((s) => s.aviso, 'aviso', 'Sin conexión.'),
    ],
  );

  blocTest<NotificationSettingsCubit, NotificationSettingsState>(
    'si no puede cargar queda en error',
    setUp: () => when(
      () => repositorio.ajustes(),
    ).thenThrow(const AppException('Sin conexión.')),
    build: () => NotificationSettingsCubit(repositorio),
    act: (cubit) => cubit.cargar(),
    skip: 1,
    expect: () => [
      const NotificationSettingsState(
        estado: EstadoAjustes.error,
        mensaje: 'Sin conexión.',
      ),
    ],
  );
}
