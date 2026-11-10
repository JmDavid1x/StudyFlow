import 'package:flutter_test/flutter_test.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/actividad_con_nota.dart';
import 'package:studyflow/features/subjects/domain/periodo_por_defecto.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';
import 'package:studyflow/features/subjects/domain/usecases/guardar_materia.dart';
import 'package:studyflow/features/subjects/domain/usecases/terminar_configuracion.dart';

import 'fixtures_materias.dart';

/// Repositorio falso que anota lo que le piden.
class _RepoFalso implements SubjectsRepository {
  _RepoFalso({this.periodo});

  Periodo? periodo;
  final llamadas = <String>[];
  Materia? materiaCreada;
  bool? pushGuardado;
  PeriodoPorDefecto? periodoCreado;

  @override
  Future<Periodo?> periodoActivo() async => periodo;

  @override
  Future<Periodo> crearPeriodo({
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    double? metaPromedio,
  }) async {
    llamadas.add('crearPeriodo');
    periodoCreado = PeriodoPorDefecto(
      nombre: nombre,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
    return periodo = Periodo(
      id: 'nuevo',
      perfilId: 'u1',
      nombre: nombre,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      activo: true,
    );
  }

  @override
  Future<Materia> crearMateria(
    Materia materia,
    List<HorarioClase> horarios,
    List<ComponenteNota> componentes,
  ) async {
    llamadas.add('crearMateria');
    return materiaCreada = materia;
  }

  @override
  Future<void> terminarConfiguracion({required bool pushActivas}) async {
    llamadas.add('terminarConfiguracion');
    pushGuardado = pushActivas;
  }

  @override
  Future<List<Materia>> materiasDelPeriodo() => throw UnimplementedError();

  @override
  Future<List<ActividadConNota>> actividadesConNota(String materiaId) =>
      throw UnimplementedError();

  @override
  Future<void> registrarNota(String actividadId, double nota) =>
      throw UnimplementedError();
}

Periodo _periodo() => Periodo(
  id: 'p-existente',
  perfilId: 'u1',
  nombre: '2026-2',
  fechaInicio: DateTime(2026, 8, 3),
  fechaFin: DateTime(2026, 12, 5),
  activo: true,
);

void main() {
  final componentes = [
    componenteDePrueba('', porcentaje: 60),
    componenteDePrueba('', porcentaje: 40),
  ];

  Future<Materia> guardar(
    _RepoFalso repo, {
    String nombre = '  Cálculo  ',
    String? profesor = ' Laura ',
    List<ComponenteNota>? comps,
  }) => GuardarMateria(repo, reloj: () => DateTime(2026, 11, 9))(
    nombre: nombre,
    profesor: profesor,
    creditos: 4,
    colorHex: '#A78BFA',
    metaNota: 4.0,
    horarios: const [],
    componentes: comps ?? componentes,
  );

  test('con periodo activo guarda la materia en ese periodo', () async {
    final repo = _RepoFalso(periodo: _periodo());

    await guardar(repo);

    expect(repo.llamadas, ['crearMateria']);
    expect(repo.materiaCreada?.periodoId, 'p-existente');
    expect(repo.materiaCreada?.nombre, 'Cálculo');
    expect(repo.materiaCreada?.profesor, 'Laura');
  });

  test('sin periodo crea primero el del semestre actual', () async {
    final repo = _RepoFalso();

    await guardar(repo);

    expect(repo.llamadas, ['crearPeriodo', 'crearMateria']);
    expect(repo.periodoCreado?.nombre, '2026-2');
    expect(repo.materiaCreada?.periodoId, 'nuevo');
  });

  test('profesor vacío se guarda como nulo', () async {
    final repo = _RepoFalso(periodo: _periodo());

    await guardar(repo, profesor: '   ');

    expect(repo.materiaCreada?.profesor, isNull);
  });

  test('si los componentes no suman 100 no crea ni el periodo', () async {
    final repo = _RepoFalso();

    await expectLater(
      guardar(repo, comps: [componenteDePrueba('', porcentaje: 60)]),
      throwsA(isA<AppException>()),
    );

    expect(repo.llamadas, isEmpty);
  });

  test('si el nombre está vacío lanza AppException', () async {
    final repo = _RepoFalso(periodo: _periodo());

    await expectLater(guardar(repo, nombre: ' '), throwsA(isA<AppException>()));
    expect(repo.llamadas, isEmpty);
  });

  test(
    'TerminarConfiguracion guarda si se activaron los recordatorios',
    () async {
      final repo = _RepoFalso();

      await TerminarConfiguracion(repo)(pushActivas: true);

      expect(repo.pushGuardado, isTrue);
    },
  );
}
