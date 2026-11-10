import 'package:flutter_test/flutter_test.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/actividad_con_nota.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';
import 'package:studyflow/features/subjects/domain/usecases/crear_materia.dart';
import 'package:studyflow/features/subjects/domain/usecases/registrar_nota.dart';

/// Repositorio falso que solo guarda lo que le llega.
class _RepoFalso implements SubjectsRepository {
  Materia? materiaCreada;
  double? notaGuardada;

  @override
  Future<Materia> crearMateria(
    Materia materia,
    List<HorarioClase> horarios,
    List<ComponenteNota> componentes,
  ) async {
    materiaCreada = materia;
    return materia;
  }

  @override
  Future<void> registrarNota(String actividadId, double nota) async =>
      notaGuardada = nota;

  @override
  Future<Periodo?> periodoActivo() => throw UnimplementedError();

  @override
  Future<Periodo> crearPeriodo({
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    double? metaPromedio,
  }) => throw UnimplementedError();

  @override
  Future<List<Materia>> materiasDelPeriodo() => throw UnimplementedError();

  @override
  Future<List<ActividadConNota>> actividadesConNota(String materiaId) =>
      throw UnimplementedError();

  @override
  Future<void> terminarConfiguracion({required bool pushActivas}) =>
      throw UnimplementedError();
}

ComponenteNota _componente(double porcentaje) => ComponenteNota(
  id: '',
  materiaId: '',
  nombre: 'Parte',
  porcentaje: porcentaje,
);

Materia _materia({String nombre = 'Bases de Datos', double? meta = 4.0}) =>
    Materia(
      id: '',
      periodoId: 'p1',
      nombre: nombre,
      creditos: 3,
      colorHex: '#A78BFA',
      metaNota: meta,
    );

void main() {
  late _RepoFalso repo;

  setUp(() => repo = _RepoFalso());

  group('CrearMateria', () {
    test('guarda cuando los componentes suman 100', () async {
      await CrearMateria(repo)(_materia(), const [], [
        _componente(60),
        _componente(40),
      ]);
      expect(repo.materiaCreada?.nombre, 'Bases de Datos');
    });

    test('rechaza componentes que no suman 100', () {
      expect(
        () => CrearMateria(repo)(_materia(), const [], [
          _componente(60),
          _componente(30),
        ]),
        throwsA(isA<AppException>()),
      );
      expect(repo.materiaCreada, isNull);
    });

    test('rechaza meta fuera de 0 a 5', () {
      expect(
        () => CrearMateria(repo)(_materia(meta: 5.5), const [], [
          _componente(100),
        ]),
        throwsA(isA<AppException>()),
      );
    });

    test('rechaza nombre vacío', () {
      expect(
        () => CrearMateria(repo)(_materia(nombre: '  '), const [], [
          _componente(100),
        ]),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('RegistrarNota', () {
    test('redondea a un decimal', () async {
      await RegistrarNota(repo)('a1', 3.74);
      expect(repo.notaGuardada, 3.7);
    });

    test('rechaza notas fuera de 0 a 5', () {
      expect(
        () => RegistrarNota(repo)('a1', 5.1),
        throwsA(isA<AppException>()),
      );
      expect(() => RegistrarNota(repo)('a1', -1), throwsA(isA<AppException>()));
      expect(repo.notaGuardada, isNull);
    });
  });
}
