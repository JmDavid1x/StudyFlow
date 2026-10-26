import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subscription/ui/widgets/subscription_demo.dart';

/// Tabla Gratis vs Plus. La columna Plus va resaltada en violeta.
class PlanComparisonTable extends StatelessWidget {
  const PlanComparisonTable({super.key, required this.features});

  final List<PlanFeature> features;

  @override
  Widget build(BuildContext context) {
    if (features.isEmpty) {
      return const SfEmptyState(
        icon: Icons.table_rows_outlined,
        title: 'No hay beneficios para comparar',
        message: 'Vuelve a abrir StudyFlow Plus para ver qué incluye cada plan.',
      );
    }
    return SfCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _row(
            name: Text('Incluye', style: SfTypography.label.copyWith(color: SfColors.textSecondary)),
            free: Text('Gratis', style: SfTypography.label.copyWith(color: SfColors.textSecondary)),
            plus: Text('Plus', style: SfTypography.label.copyWith(color: SfColors.primaryLight)),
          ),
          for (final feature in features) ...[
            const Divider(height: 1, color: SfColors.border),
            _row(
              name: Text(feature.name, style: SfTypography.body),
              free: _cell(feature.free, SfColors.textSecondary),
              plus: _cell(feature.plus, SfColors.primaryLight),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row({required Widget name, required Widget free, required Widget plus}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.md, vertical: SfSpacing.sm),
      child: Row(
        children: [
          Expanded(flex: 5, child: name),
          Expanded(flex: 3, child: Center(child: free)),
          Expanded(flex: 3, child: Center(child: plus)),
        ],
      ),
    );
  }

  Widget _cell(String? text, Color color) {
    if (text == null) return Icon(Icons.check_rounded, color: color);
    return Text(
      text,
      textAlign: TextAlign.center,
      style: SfTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}
