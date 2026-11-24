import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';
import 'package:studyflow/features/subjects/subjects_di.dart';
import 'package:studyflow/features/subjects/ui/bloc/subjects_cubit.dart';

/// Repositorio falso: anota cada método que le piden y responde con error.
class RepositorioFalso implements SubjectsRepository {
  final llamadas = <String>[];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    llamadas.add(invocation.memberName.toString());
    throw const AppException('falso');
  }
}

void main() {
  late RepositorioFalso falso;

  setUp(() {
    sl.reset();
    sl.allowReassignment = true;
    registrarSubjects(sl); // los registros reales de mi parte
    falso = RepositorioFalso();
    sl.registerSingleton<SubjectsRepository>(falso); // cambio Supabase por el falso
  });

  tearDown(() => sl.reset());

  test('SubjectsCubit pide los datos al repositorio registrado en sl', () async {
    final cubit = sl<SubjectsCubit>();
    await cubit.cargar();

    expect(falso.llamadas, isNotEmpty);
    await cubit.close();
  });
}