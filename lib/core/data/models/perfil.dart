import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/models/parse.dart';
import 'package:studyflow/core/data/models/universidad.dart';

/// Tabla `perfiles`. Su id es el mismo del usuario de Supabase Auth.
/// Lo crea la base al registrarse; la app solo lo lee y lo actualiza.
class Perfil extends Equatable {
  const Perfil({
    required this.id,
    required this.universidadId,
    required this.nombre,
    required this.correo,
    required this.configuracionCompleta,
    required this.creadoEn,
    this.programa,
    this.semestre,
    this.universidad,
  });

  /// Select con la universidad incluida.
  static const select = '*, universidades(*)';

  factory Perfil.fromMap(Map<String, dynamic> map) {
    final universidad = anidado(map['universidades']);
    return Perfil(
      id: map['id'] as String,
      universidadId: map['universidad_id'] as String,
      nombre: map['nombre'] as String,
      correo: map['correo'] as String,
      programa: map['programa'] as String?,
      semestre: map['semestre'] as int?,
      configuracionCompleta: map['configuracion_completa'] as bool,
      creadoEn: fecha(map['creado_en']),
      universidad: universidad == null ? null : Universidad.fromMap(universidad),
    );
  }

  final String id;
  final String universidadId;
  final String nombre;
  final String correo;
  final String? programa;
  final int? semestre;

  /// Terminó la configuración inicial (materias y recordatorios).
  final bool configuracionCompleta;
  final DateTime creadoEn;

  /// Solo viene si se pidió con [select].
  final Universidad? universidad;

  /// Primer nombre para el saludo de Inicio: "Hola, Santiago".
  String get primerNombre => nombre.trim().split(' ').first;

  @override
  List<Object?> get props => [id, universidadId, nombre, correo, programa, semestre, configuracionCompleta, creadoEn];
}
