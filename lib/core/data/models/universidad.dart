import 'package:equatable/equatable.dart';

/// Tabla `universidades` (catálogo, solo lectura).
class Universidad extends Equatable {
  const Universidad({required this.id, required this.nombre, required this.dominioCorreo});

  factory Universidad.fromMap(Map<String, dynamic> map) => Universidad(
        id: map['id'] as String,
        nombre: map['nombre'] as String,
        dominioCorreo: map['dominio_correo'] as String,
      );

  final String id;
  final String nombre;

  /// 'u.icesi.edu.co'
  final String dominioCorreo;

  @override
  List<Object?> get props => [id, nombre, dominioCorreo];
}
