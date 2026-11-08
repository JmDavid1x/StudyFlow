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

  setUp(() {
    repositorio = _MockTasksRepository();
    when(() => repositorio.completar(any())).thenAnswer((_) async {});
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
        verify(() => repositorio.completar(tarea.id)).called(1);
      }
    });

    test('no completa un examen ni algo ya cerrado', () {
      final examen = actividad('e1', tipo: TipoActividad.examen, fecha: manana);
      final cerrada = actividad('a1', fecha: manana, estado: EstadoActividad.completada);
      expect(() => CompletarActividad(repositorio)(examen), throwsA(isA<AppException>()));
      expect(() => CompletarActividad(repositorio)(cerrada), throwsA(isA<AppException>()));
      verifyNever(() => repositorio.completar(any()));
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
