import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Marca de StudyFlow: el libro sobre el círculo violeta del prototipo.
/// Se usa en el splash y en el inicio de sesión.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'StudyFlow',
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: SfColors.primary, shape: BoxShape.circle),
        child: Icon(Icons.menu_book_rounded, size: size * 0.46, color: SfColors.textPrimary),
      ),
    );
  }
}
