import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/features/home/domain/home_repository.dart';
import 'package:studyflow/features/home/home_di.dart';
import 'package:studyflow/features/home/ui/bloc/home_cubit.dart';
import 'package:studyflow/features/home/ui/bloc/notifications_cubit.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';
import 'package:studyflow/features/tasks/domain/usecases/completar_actividad.dart';
import 'package:studyflow/features/tasks/tasks_di.dart';
import 'package:studyflow/features/tasks/ui/bloc/task_detail_cubit.dart';
import 'package:studyflow/features/tasks/ui/bloc/tasks_bloc.dart';

import 'fixtures.dart';

class _FalsoTasksRepository extends Mock implements TasksRepository {}

class _FalsoHomeRepository extends Mock implements HomeRepository {}

/// GetIt de Inicio y Tareas: se registran las partes reales y se cambian los
/// repositorios por falsos. Así se prueba que los Blocs que entrega `sl` usan
/// lo que está registrado (y no crean Supabase por su cuenta).
void main() {
  late _FalsoTasksRepository tareas;
  late _FalsoHomeRepository inicio;
  final tarea = actividad('a1', fecha: DateTime(2030, 1, 10));

  setUp(() async {
    await sl.reset();
    registrarTasks(sl);
    registrarHome(sl);

    tareas = _FalsoTasksRepository();
    inicio = _FalsoHomeRepository();
    await sl.unregister<TasksRepository>();
    await sl.unregister<HomeRepository>();
    sl.registerSingleton<TasksRepository>(tareas);
    sl.registerSingleton<HomeRepository>(inicio);

    when(() => tareas.actividadesDelPeriodo()).thenAnswer((_) async => [tarea]);
    when(() => tareas.bloquesDeActividad(any())).thenAnswer((_) async => []);
  });

  tearDown(() => sl.reset());

  test('TasksBloc sale de GetIt y carga con el repositorio registrado', () async {
    final bloc = sl<TasksBloc>()..add(const TareasPedidas());
    await expectLater(
      bloc.stream,
      emitsThrough(isA<TasksState>().having((s) => s.estado, 'estado', EstadoTareas.listo)),
    );
    verify(() => tareas.actividadesDelPeriodo()).called(1);
    await bloc.close();
  });

  test('TaskDetailCubit recibe la Actividad de la ruta (registerFactoryParam)', () async {
    final cubit = sl<TaskDetailCubit>(param1: tarea);
    expect(cubit.state.actividad, tarea);
    await cubit.cargarBloques();
    verify(() => tareas.bloquesDeActividad('a1')).called(1);
    await cubit.close();
  });

  test('los Blocs y casos de uso son nuevos cada vez; el repositorio es uno solo', () async {
    final a = sl<TasksBloc>();
    final b = sl<TasksBloc>();
    expect(a, isNot(same(b)));
    expect(sl<CompletarActividad>(), isNot(same(sl<CompletarActividad>())));
    expect(sl<TasksRepository>(), same(tareas));
    await a.close();
    await b.close();
  });

  test('HomeCubit y NotificationsCubit se arman con los repositorios registrados', () async {
    final home = sl<HomeCubit>();
    final avisos = sl<NotificationsCubit>();
    expect(home, isA<HomeCubit>());
    expect(avisos, isA<NotificationsCubit>());
    await home.close();
    await avisos.close();
  });
}
