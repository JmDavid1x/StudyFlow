import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';

/// Tipografía de StudyFlow.
///
/// - Raleway (bold) para títulos: le da personalidad a los encabezados.
/// - DM Sans para todo lo que se lee: buena lectura en tamaños pequeños.
/// - DM Mono solo para cifras alineadas (notas, porcentajes, horas).
abstract final class SfTypography {
  /// Título grande de las pestañas: "Calendario", "Tareas".
  static TextStyle get display => GoogleFonts.raleway(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.15,
        color: SfColors.textPrimary,
      );

  /// Título principal de una pantalla: "Crea tu cuenta".
  static TextStyle get h1 => GoogleFonts.raleway(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: SfColors.textPrimary,
      );

  /// Encabezado de sección: "Prioridades de hoy".
  static TextStyle get h2 => GoogleFonts.raleway(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: SfColors.textPrimary,
      );

  /// Título de la barra superior y de tarjetas.
  static TextStyle get title => GoogleFonts.dmSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: SfColors.textPrimary,
      );

  static TextStyle get bodyStrong => GoogleFonts.dmSans(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: SfColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: SfColors.textPrimary,
      );

  static TextStyle get button => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: SfColors.textPrimary,
      );

  /// Etiqueta encima de un campo: "Correo".
  static TextStyle get label => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: SfColors.textSecondary,
      );

  /// Texto secundario: fechas, materias, ayudas.
  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: SfColors.textSecondary,
      );

  /// Cifras: "4.1", "30 %", "7:00".
  static TextStyle get number => GoogleFonts.dmMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: SfColors.textPrimary,
      );
}
