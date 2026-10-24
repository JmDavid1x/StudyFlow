import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_radius.dart';
import 'package:studyflow/core/design_system/tokens/sf_typography.dart';

/// Tema de Material configurado con los tokens.
///
/// StudyFlow es oscura a propósito: se usa mucho de noche, al planear el día
/// siguiente, y el violeta de la acción principal resalta sobre el fondo.
abstract final class SfTheme {
  static ThemeData get dark {
    final baseText = ThemeData(brightness: Brightness.dark).textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: SfColors.primary,
        onPrimary: SfColors.textPrimary,
        secondary: SfColors.primaryLight,
        onSecondary: SfColors.background,
        surface: SfColors.surface,
        onSurface: SfColors.textPrimary,
        error: SfColors.danger,
        onError: SfColors.background,
        outline: SfColors.border,
      ),
      scaffoldBackgroundColor: SfColors.background,
      canvasColor: SfColors.background,
      textTheme: GoogleFonts.dmSansTextTheme(baseText).apply(
        bodyColor: SfColors.textPrimary,
        displayColor: SfColors.textPrimary,
      ),
      dividerTheme: const DividerThemeData(
        color: SfColors.border,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? SfColors.textPrimary
              : SfColors.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? SfColors.primary
              : SfColors.border,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SfColors.primary,
        foregroundColor: SfColors.textPrimary,
        shape: CircleBorder(),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SfColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(SfRadius.sheet)),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: SfColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: SfColors.primarySoft,
        headerForegroundColor: SfColors.textPrimary,
        todayBorder: const BorderSide(color: SfColors.primaryLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SfRadius.lg),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: SfColors.surfaceRaised,
        dialBackgroundColor: SfColors.surface,
        dialHandColor: SfColors.primary,
        hourMinuteColor: SfColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SfRadius.lg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SfColors.surfaceRaised,
        contentTextStyle: SfTypography.body,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SfRadius.md),
        ),
      ),
    );
  }
}
