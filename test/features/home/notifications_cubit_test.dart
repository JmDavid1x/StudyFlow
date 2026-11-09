import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/home/domain/home_repository.dart';
import 'package:studyflow/features/home/ui/bloc/notifications_cubit.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';

import '../tasks/fixtures.dart';

class _MockHomeRepository extends Mock implements HomeRepository {}

class _MockTasksRepository extends Mock implements TasksRepository {}

void main() {
  late _MockHomeRepository inicio;
  late _MockTasksRepository tareas;
  final ahora = DateTime(2026, 11, 11, 10);
  final hoy = notificacion('n1', programadaPara: DateTime(2026, 11, 11, 9));
  final ayer = notificacion('n2', programadaPara: DateTime(2026, 11, 10, 18), leidaEn: DateTime(2026, 11, 10, 19));
  final futura = notificacion('n3', programadaPara: DateTime(2026, 11, 12, 9));
  final conTarea = Notificacion(
    id: 'n4',
    perfilId: 'p1',
    actividadId: 'a1',
    tipo: TipoNotificacion.entregaManana,
    titulo: 'Mañana vence',
    cuerpo: 'Cuerpo',
    programadaPara: DateTime(2026, 11, 11, 8),
  );
  final tarea = actividad('a1', fecha: DateTime(2026, 11, 12, 23));

  NotificationsCubit crear() => NotificationsCubit(inicio, tareas, reloj: () => ahora);

  setUp(() {
    inicio = _MockHomeRepository();
    tareas = _MockTasksRepository();
    when(() => inicio.notificaciones()).thenAnswer((_) async => [futura, hoy, conTarea, ayer]);
    when(() => inicio.marcarLeida(any())).thenAnswer((_) async {});
    when(() => inicio.borrarNotificacion(any())).thenAnswer((_) async {});
    when(() => tareas.actividadPorId('a1')).thenAnswer((_) async => tarea);
  });

  blocTest<NotificationsCubit, NotificationsState>(
    'carga sin las que todavía no llegan',
    build: crear,
    act: (cubit) => cubit.cargar(),
    skip: 1,
    expect: () => [
      isA<NotificationsState>().having((s) => s.estado, 'estado', EstadoNotificaciones.listo).having(
        (s) => s.notificaciones.map((n) => n.id).toList(),
        'ids',
        ['n1', 'n4', 'n2'],
      ),
    ],
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'si la carga falla queda en error',
    setUp: () => when(() => inicio.notificaciones()).thenThrow(const AppException('Sin conexión.')),
    build: crear,
    act: (cubit) => cubit.cargar(),
    skip: 1,
    expect: () => [isA<NotificationsState>().having((s) => s.estado, 'estado', EstadoNotificaciones.error)],
  );

  test('tocar la marca leída y devuelve su actividad', () async {
    final cubit = crear();
    await cubit.cargar();
    final abierta = await cubit.tocar(conTarea);
    expect(abierta, tarea);
    expect(cubit.state.notificaciones.firstWhere((n) => n.id == 'n4').leida, isTrue);
    verify(() => inicio.marcarLeida('n4')).called(1);
  });

  test('tocar una ya leída no la vuelve a guardar', () async {
    final cubit = crear();
    await cubit.cargar();
    expect(await cubit.tocar(ayer), isNull);
    verifyNever(() => inicio.marcarLeida(any()));
  });

  test('si no se puede marcar leída, vuelve a verse sin leer y avisa', () async {
    when(() => inicio.marcarLeida(any())).thenThrow(const AppException('Sin conexión.'));
    final cubit = crear();
    await cubit.cargar();
    await cubit.tocar(hoy);
    expect(cubit.state.notificaciones.firstWhere((n) => n.id == 'n1').leida, isFalse);
    expect(cubit.state.aviso, 'Sin conexión.');
  });

  test('borrar la quita; si falla, vuelve', () async {
    final cubit = crear();
    await cubit.cargar();
    await cubit.borrar(hoy);
    expect(cubit.state.notificaciones.map((n) => n.id), ['n4', 'n2']);
    verify(() => inicio.borrarNotificacion('n1')).called(1);

    when(() => inicio.borrarNotificacion(any())).thenThrow(const AppException('Sin conexión.'));
    await cubit.borrar(ayer);
    expect(cubit.state.notificaciones.map((n) => n.id), ['n4', 'n2']);
    expect(cubit.state.avisoId, 1);
  });
}
