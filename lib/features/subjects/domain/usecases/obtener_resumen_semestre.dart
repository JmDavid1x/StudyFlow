import 'package:studyflow/features/subjects/domain/actividad_con_nota.dart';
import 'package:studyflow/features/subjects/domain/calculo_notas.dart';
import 'package:studyflow/features/subjects/domain/resumen_semestre.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';

/// Trae las materias del periodo activo con su nota acumulada y calcula el
/// promedio del semestre.
class ObtenerResumenSemestre {
  const ObtenerResumenSemestre(this._repositorio);

  final SubjectsRepository _repositorio;

  Future<ResumenSemestre> call() async {
    final materias = await _repositorio.materiasDelPeriodo();
    final actividades = await Future.wait(
      materias.map((m) => _repositorio.actividadesConNota(m.id)),
    );

    final items = [
      for (var i = 0; i < materias.length; i++)
        MateriaConNota(
          materia: materias[i],
          resumen: ResumenNotas.desde(
            meta: materias[i].metaNota,
            notas: actividades[i].ponderadas,
          ),
        ),
    ];
    final promedio = promedioSemestre(
      items.map(
        (m) => NotaDeMateria(
          notaAcumulada: m.resumen.notaAcumulada,
          creditos: m.materia.creditos,
        ),
      ),
    );
    return ResumenSemestre(materias: items, promedio: promedio);
  }
}
