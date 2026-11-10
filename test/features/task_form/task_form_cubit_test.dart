import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';
import 'package:studyflow/features/task_form/ui/bloc/task_form_cubit.dart';
import 'package:studyflow/features/task_form/ui/bloc/task_form_state.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form_data.dart';

import '../calendar/fixtures.dart';

class _MockRepositorio extends Mock implements TaskFormRepository {}

void main() {
  const talleres = ComponenteNota(
    id: 'c1',
    materiaId: 'm1',
    nombre: 'Talleres',
    porcentaje: 30,
  );
  const bases = Materia(
    id: 'm1',
    periodoId: 'p1',
    nombre: 'Bases de Datos',
    creditos: 3,
    colorHex: '#2DD4BF',
    componentes: [talleres],
  );
  const asignados = <PorcentajeAsignado>[
    (actividadId: 'a9', componenteId: 'c1', porcentaje: 10),
  ];
  final datos = TaskFormData(
    title: 'Taller 3',
    materia: bases,
    componente: talleres,
    date: DateTime(2026, 11, 12),
    porcentaje: 15,
    canal: CanalEntrega.intu,
  );

  late _MockRepositorio repositorio;

  setUpAll(
    () => registerFallbackValue(actividad('fallback', fecha: DateTime(2026))),
  );

  setUp(() {
    repositorio = _MockRepositorio();
    when(
      () => repositorio.materiasConComponentes(),
    ).thenAnswer((_) async => [bases]);
    when(
      () => repositorio.porcentajesAsignados(),
    ).thenAnswer((_) async => asignados);
    when(
      () => repositorio.crearActividad(any()),
    ).thenAnswer((i) async => i.positionalArguments.first as Actividad);
    when(
      () => repositorio.editarActividad(any()),
    ).thenAnswer((i) async => i.positionalArguments.first as Actividad);
  });

  group('cargar', () {
    blocTest<TaskFormCubit, TaskFormState>(
      'trae las materias y lo ya asignado',
      build: () => TaskFormCubit(repositorio),
      act: (cubit) => cubit.cargar(),
      expect: () => [
        const TaskFormState(),
        const TaskFormState(
          status: TaskFormStatus.listo,
          materias: [bases],
          asignados: asignados,
        ),
      ],
    );

    blocTest<TaskFormCubit, TaskFormState>(
      'muestra el error si no se pudo cargar',
      setUp: () => when(
        () => repositorio.materiasConComponentes(),
      ).thenThrow(const AppException('Sin conexión.')),
      build: () => TaskFormCubit(repositorio),
      act: (cubit) => cubit.cargar(),
      expect: () => [
        const TaskFormState(),
        const TaskFormState(
          status: TaskFormStatus.error,
          errorCarga: 'Sin conexión.',
        ),
      ],
    );
  });

  group('guardar', () {
    blocTest<TaskFormCubit, TaskFormState>(
      'una tarea nueva se crea por hacer y llega guardada',
      build: () => TaskFormCubit(repositorio),
      act: (cubit) => cubit.guardar(datos),
      expect: () => [
        const TaskFormState(guardando: true),
        isA<TaskFormState>()
            .having((s) => s.guardando, 'guardando', false)
            .having((s) => s.guardada?.titulo, 'título', 'Taller 3')
            .having(
              (s) => s.guardada?.estado,
              'estado',
              EstadoActividad.porHacer,
            ),
      ],
      verify: (_) {
        verify(() => repositorio.crearActividad(any())).called(1);
        verifyNever(() => repositorio.editarActividad(any()));
      },
    );

    blocTest<TaskFormCubit, TaskFormState>(
      'al editar conserva el id y el estado de la actividad',
      build: () => TaskFormCubit(repositorio),
      act: (cubit) => cubit.guardar(
        datos,
        original: actividad(
          'a1',
          fecha: DateTime(2026, 11, 12),
          estado: EstadoActividad.enProgreso,
        ),
      ),
      skip: 1,
      expect: () => [
        isA<TaskFormState>()
            .having((s) => s.guardada?.id, 'id', 'a1')
            .having(
              (s) => s.guardada?.estado,
              'estado',
              EstadoActividad.enProgreso,
            ),
      ],
      verify: (_) => verify(() => repositorio.editarActividad(any())).called(1),
    );

    blocTest<TaskFormCubit, TaskFormState>(
      'si falla, avisa sin perder el formulario',
      setUp: () => when(
        () => repositorio.crearActividad(any()),
      ).thenThrow(const AppException('No pudimos guardar los cambios.')),
      build: () => TaskFormCubit(repositorio),
      act: (cubit) => cubit.guardar(datos),
      expect: () => [
        const TaskFormState(guardando: true),
        const TaskFormState(errorGuardar: 'No pudimos guardar los cambios.'),
      ],
    );
  });

  group('TaskFormData', () {
    test('sin hora, la entrega queda a las 11:59 p. m.', () {
      final a = datos.toActividad();
      expect(a.fechaLimite, DateTime(2026, 11, 12, 23, 59));
      expect(a.componenteId, 'c1');
      expect(a.porcentaje, 15.0);
    });

    test('un examen no lleva canal de entrega', () {
      final examen = TaskFormData(
        title: 'Parcial 2',
        materia: bases,
        componente: talleres,
        tipo: TipoActividad.examen,
        date: DateTime(2026, 11, 12),
        time: const TimeOfDay(hour: 14, minute: 0),
        canal: CanalEntrega.intu,
        place: 'Salón 302',
      ).toActividad();
      expect(examen.canalEntrega, isNull);
      expect(examen.lugar, 'Salón 302');
      expect(examen.fechaLimite, DateTime(2026, 11, 12, 14));
    });

    test('fromActividad encuentra la materia por su componente', () {
      final cargada = TaskFormData.fromActividad(
        actividad('a1', fecha: DateTime(2026, 11, 12, 18, 30)),
        [bases],
      );
      expect(cargada.materia, bases);
      expect(cargada.componente, talleres);
      expect(cargada.date, DateTime(2026, 11, 12));
      expect(cargada.time, const TimeOfDay(hour: 18, minute: 30));
    });
  });
}
