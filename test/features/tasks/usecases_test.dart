import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';
import 'package:studyflow/features/tasks/domain/usecases/completar_actividad.dart';
import 'package:studyflow/features/tasks/domain/usecases/eliminar_actividad.dart';
import 'package:studyflow/features/tasks/domain/usecases/marcar_no_entregada.dart';
import 'package:studyflow/features/tasks/domain/usecases/marcar_presentado.dart';

import 'fixtures.dart';

class _MockTasksRepository extends Mock implements TasksRepository {}

void main() {
  late _MockTasksRepository repositorio;
  final ahora = DateTime(2026, 11, 11, 10);
  final manana = DateTime(2026, 11, 12, 10);
  final ayer = DateTime(2026, 11, 10, 10);

  setUpAll(() => registerFallbackValue(EstadoActividad.porHacer));

  setUp(() {
    repositorio = _MockTasksRepository();
    when(() => repositorio.marcarCompletada(any())).thenAnswer((_) async {});
    when(() => repositorio.cancelarBloquesPendientes(any())).thenAnswer((_) async {});
    when(() => repositorio.restaurarEstado(any(), any())).thenAnswer((_) async {});
    when(() => repositorio.marcarNoEntregada(any())).thenAnswer((_) async {});
    when(() => repositorio.marcarPresentado(any())).thenAnswer((_) async {});
    when(() => repositorio.eliminar(any())).thenAnswer((_) async {});
  });

  group('CompletarActividad', () {
    test('completa una tarea por hacer, en progreso o vencida', () async {
      final casos = [
        actividad('a1', fecha: manana),
        actividad('a2', fecha: manana, estado: EstadoActividad.enProgreso),
        actividad('a3', fecha: ayer, estado: EstadoActividad.vencida),
      ];
      for (final tarea in casos) {
        await CompletarActividad(repositorio)(tarea);
        verify(() => repositorio.marcarCompletada(tarea.id)).called(1);
      }
    });

    test('completa la tarea y después cancela sus bloques pendientes', () async {
      final tarea = actividad('a1', fecha: manana);
      await CompletarActividad(repositorio)(tarea);
      verifyInOrder([() => repositorio.marcarCompletada('a1'), () => repositorio.cancelarBloquesPendientes('a1')]);
      verifyNever(() => repositorio.restaurarEstado(any(), any()));
    });

    test('si falla al marcarla no toca los bloques y avisa con el mensaje', () async {
      when(() => repositorio.marcarCompletada(any())).thenThrow(const AppException('Sin conexión.'));
      final tarea = actividad('a1', fecha: manana);
      await expectLater(
        CompletarActividad(repositorio)(tarea),
        throwsA(isA<AppException>().having((e) => e.mensaje, 'mensaje', 'Sin conexión.')),
      );
      verifyNever(() => repositorio.cancelarBloquesPendientes(any()));
      verifyNever(() => repositorio.restaurarEstado(any(), any()));
    });

    test('si fallan los bloques la devuelve a su estado anterior y avisa', () async {
      when(() => repositorio.cancelarBloquesPendientes(any())).thenThrow(const AppException('Sin conexión.'));
      final tarea = actividad('a1', fecha: manana, estado: EstadoActividad.enProgreso);
      await expectLater(
        CompletarActividad(repositorio)(tarea),
        throwsA(isA<AppException>().having((e) => e.mensaje, 'mensaje', 'Sin conexión.')),
      );
      verify(() => repositorio.restaurarEstado('a1', EstadoActividad.enProgreso)).called(1);
    });

    test('si tampoco se puede deshacer, lo dice claro', () async {
      when(() => repositorio.cancelarBloquesPendientes(any())).thenThrow(const AppException('Sin conexión.'));
      when(() => repositorio.restaurarEstado(any(), any())).thenThrow(const AppException('Sin conexión.'));
      await expectLater(
        CompletarActividad(repositorio)(actividad('a1', fecha: manana)),
        throwsA(isA<AppException>().having((e) => e.mensaje, 'mensaje', CompletarActividad.mensajeAMedias)),
      );
    });

    test('un error técnico llega como mensaje en español', () async {
      when(() => repositorio.marcarCompletada(any())).thenThrow(Exception('socket closed'));
      await expectLater(
        CompletarActividad(repositorio)(actividad('a1', fecha: manana)),
        throwsA(isA<AppException>().having((e) => e.mensaje, 'mensaje', 'Algo salió mal. Intenta de nuevo.')),
      );
    });

    test('no completa un examen ni algo ya cerrado', () {
      final examen = actividad('e1', tipo: TipoActividad.examen, fecha: manana);
      final cerrada = actividad('a1', fecha: manana, estado: EstadoActividad.completada);
      expect(() => CompletarActividad(repositorio)(examen), throwsA(isA<AppException>()));
      expect(() => CompletarActividad(repositorio)(cerrada), throwsA(isA<AppException>()));
      verifyNever(() => repositorio.marcarCompletada(any()));
    });
  });

  group('MarcarNoEntregada', () {
    test('solo si la tarea ya venció', () async {
      final vencida = actividad('a1', fecha: ayer);
      await MarcarNoEntregada(repositorio)(vencida, ahora: ahora);
      verify(() => repositorio.marcarNoEntregada('a1')).called(1);

      final aTiempo = actividad('a2', fecha: manana);
      expect(() => MarcarNoEntregada(repositorio)(aTiempo, ahora: ahora), throwsA(isA<AppException>()));
      verifyNever(() => repositorio.marcarNoEntregada('a2'));
    });

    test('no aplica a exámenes ni a tareas cerradas', () {
      final examen = actividad('e1', tipo: TipoActividad.examen, fecha: ayer);
      final completada = actividad('a1', fecha: ayer, estado: EstadoActividad.completada);
      expect(MarcarNoEntregada.puede(examen, ahora), isFalse);
      expect(MarcarNoEntregada.puede(completada, ahora), isFalse);
    });
  });

  group('MarcarPresentado', () {
    test('examen pendiente → presentado', () async {
      final examen = actividad('e1', tipo: TipoActividad.examen, fecha: ayer);
      await MarcarPresentado(repositorio)(examen);
      verify(() => repositorio.marcarPresentado('e1')).called(1);
    });

    test('no aplica a tareas ni a exámenes ya presentados', () {
      final tarea = actividad('a1', fecha: ayer);
      final presentado = actividad('e1', tipo: TipoActividad.examen, fecha: ayer, estado: EstadoActividad.presentado);
      expect(() => MarcarPresentado(repositorio)(tarea), throwsA(isA<AppException>()));
      expect(() => MarcarPresentado(repositorio)(presentado), throwsA(isA<AppException>()));
      verifyNever(() => repositorio.marcarPresentado(any()));
    });
  });

  test('EliminarActividad borra por id', () async {
    await EliminarActividad(repositorio)(actividad('a1', fecha: manana));
    verify(() => repositorio.eliminar('a1')).called(1);
  });
}
