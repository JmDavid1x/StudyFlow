import 'package:flutter/material.dart';

/// Paleta de StudyFlow. Sale del prototipo de Figma.
///
/// Regla: ninguna pantalla escribe un `Color(0xFF...)` a mano. Si falta un
/// color, se agrega aquí y se documenta en docs/design-system.md.
abstract final class SfColors {
  // Fondos, del más profundo al más alto.
  static const background = Color(0xFF0A0812);
  static const surface = Color(0xFF16122A);
  static const surfaceRaised = Color(0xFF17122C);
  static const primarySoft = Color(0xFF1E1540);

  // Bordes.
  static const border = Color(0xFF2A2445);
  static const borderStrong = Color(0xFF3A2F66);

  // Marca: un solo violeta para la acción principal y su versión clara para
  // texto y estados activos.
  static const primary = Color(0xFF7C3AED);
  static const primaryLight = Color(0xFFA78BFA);

  // Texto.
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA9A3C2);
  static const textDisabled = Color(0xFF6B6685);

  // Estados: cada uno significa una sola cosa.
  static const success = Color(0xFF22C55E); // completada, guardado
  static const successLight = Color(0xFF86EFAC);
  static const warning = Color(0xFFF59E0B); // prioridad media, por vencer
  static const warningLight = Color(0xFFFCD34D);
  static const danger = Color(0xFFF87171); // prioridad alta, vencida, error
  static const info = Color(0xFF2DD4BF); // bloques de estudio, entregas

  /// Colores que el usuario elige para identificar cada materia.
  static const subjectColors = <Color>[
    primaryLight,
    warning,
    info,
    Color(0xFFF472B6),
    Color(0xFF60A5FA),
    successLight,
  ];
}
