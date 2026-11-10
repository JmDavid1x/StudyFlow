import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/task_form/domain/porcentaje_componente.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';
import 'package:studyflow/features/task_form/domain/usecases/guardar_actividad.dart';

import '../calendar/fixtures.dart';

class _MockRepositorio extends Mock implements TaskFormRepository {}

void main() {
  final fecha = DateTime(2026, 11, 12, 23, 59);

  group('GuardarActividad.preparar', () {
    test('una tarea nueva queda por hacer y con su canal', () {
      final lista = GuardarActividad.preparar(
        actividad('a', fecha: fecha, estado: EstadoActividad.completada),
        esNueva: true,
      );
      expect(lista.estado, EstadoActividad.porHacer);
      expect(lista.canalEntrega, CanalEntrega.intu);
      expect(lista.lugar, isNull);
    });

    test('un examen nuevo queda pendiente, sin canal y con lugar opcional', () {
      final examen = actividad(
        'e',
        fecha: fecha,
        tipo: TipoActividad.examen,
      ).copyWith(canalEntrega: CanalEntrega.correo, lugar: '  Salón 302  ');
      final listo = GuardarActividad.preparar(examen, esNueva: true);
      expect(listo.estado, EstadoActividad.pendiente);
      expect(listo.canalEntrega, isNull);
      expect(listo.lugar, 'Salón 302');

      final sinLugar = GuardarActividad.preparar(
        examen.copyWith(lugar: '   '),
        esNueva: true,
      );
      expect(sinLugar.lugar, isNull);
    });

    test('una tarea sin canal no se guarda', () {
      final sinCanal = Actividad(
        id: '',
        componenteId: 'c1',
        titulo: 'Taller',
        tipo: TipoActividad.tarea,
        fechaLimite: fecha,
        porcentaje: 10,
        prioridad: Prioridad.media,
        estado: EstadoActividad.porHacer,
        recordatorio: true,
        creadoEn: fecha,
        actualizadoEn: fecha,
      );
      expect(
        () => GuardarActividad.preparar(sinCanal, esNueva: true),
        throwsA(isA<AppException>()),
      );
    });

    test('pide título y porcentaje entre 0 y 100', () {
      final base = actividad('a', fecha: fecha);
      expect(
        () => GuardarActividad.preparar(
          base.copyWith(titulo: '   '),
          esNueva: true,
        ),
        throwsA(isA<AppException>()),
      );
      expect(
        () => GuardarActividad.preparar(
          base.copyWith(porcentaje: 120),
          esNueva: true,
        ),
        throwsA(isA<AppException>()),
      );
      expect(
        () => GuardarActividad.preparar(
          base.copyWith(porcentaje: -1),
          esNueva: true,
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('al editar conserva el estado de la tarea', () {
      final enProgreso = actividad(
        'a',
        fecha: fecha,
        estado: EstadoActividad.enProgreso,
      );
      expect(
        GuardarActividad.preparar(enProgreso, esNueva: false).estado,
        EstadoActividad.enProgreso,
      );
    });

    test('al cambiar de examen a tarea le pone un estado de tarea', () {
      final eraExamen = actividad(
        'a',
        fecha: fecha,
        estado: EstadoActividad.pendiente,
      );
      expect(
        GuardarActividad.preparar(eraExamen, esNueva: false).estado,
        EstadoActividad.porHacer,
      );

      final eraTarea = actividad(
        'e',
        fecha: fecha,
        tipo: TipoActividad.examen,
        estado: EstadoActividad.enProgreso,
      );
      expect(
        GuardarActividad.preparar(eraTarea, esNueva: false).estado,
        EstadoActividad.pendiente,
      );
    });
  });

  group('GuardarActividad', () {
    late _MockRepositorio repositorio;

    setUpAll(() => registerFallbackValue(actividad('fallback', fecha: fecha)));

    setUp(() {
      repositorio = _MockRepositorio();
      when(
        () => repositorio.crearActividad(any()),
      ).thenAnswer((i) async => i.positionalArguments.first as Actividad);
      when(
        () => repositorio.editarActividad(any()),
      ).thenAnswer((i) async => i.positionalArguments.first as Actividad);
    });

    test('crear manda la actividad ya preparada', () async {
      final creada = await GuardarActividad(
        repositorio,
      ).crear(actividad('a', fecha: fecha, estado: EstadoActividad.vencida));
      expect(creada.estado, EstadoActividad.porHacer);
      verify(() => repositorio.crearActividad(any())).called(1);
    });

    test('si no pasa las reglas no llama al repositorio', () {
      expect(
        () => GuardarActividad(
          repositorio,
        ).editar(actividad('a', fecha: fecha).copyWith(titulo: '')),
        throwsA(isA<AppException>()),
      );
      verifyNever(() => repositorio.editarActividad(any()));
    });
  });

  group('porcentajeRestante', () {
    const proyecto = ComponenteNota(
      id: 'c1',
      materiaId: 'm1',
      nombre: 'Proyecto',
      porcentaje: 40,
    );
    const asignados = <PorcentajeAsignado>[
      (actividadId: 'a1', componenteId: 'c1', porcentaje: 15),
      (actividadId: 'a2', componenteId: 'c1', porcentaje: 10),
      (actividadId: 'a3', componenteId: 'otro', porcentaje: 30),
    ];

    test('resta lo que ya usan las actividades del componente', () {
      expect(porcentajeRestante(proyecto, asignados), 15);
    });

    test('al editar no cuenta la actividad que se está editando', () {
      expect(porcentajeRestante(proyecto, asignados, sinContar: 'a1'), 30);
    });

    test('nunca da negativo', () {
      const pasado = <PorcentajeAsignado>[
        (actividadId: 'a1', componenteId: 'c1', porcentaje: 50),
      ];
      expect(porcentajeRestante(proyecto, pasado), 0);
    });
  });
}
