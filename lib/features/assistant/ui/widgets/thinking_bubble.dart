import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Burbuja "Pensando…" del asistente mientras la IA responde (puede tardar
/// hasta 20 s). Los tres puntos se encienden uno tras otro.
class ThinkingBubble extends StatefulWidget {
  const ThinkingBubble({super.key});

  @override
  State<ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final _animacion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _animacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'El asistente está pensando',
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: SfSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: SfSpacing.md,
            vertical: SfSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: SfColors.surface,
            border: Border.all(color: SfColors.border),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(SfRadius.lg),
              topRight: Radius.circular(SfRadius.lg),
              bottomLeft: Radius.circular(SfRadius.sm),
              bottomRight: Radius.circular(SfRadius.lg),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pensando',
                style: SfTypography.body.copyWith(
                  color: SfColors.textSecondary,
                ),
              ),
              const SizedBox(width: SfSpacing.xxs),
              AnimatedBuilder(
                animation: _animacion,
                builder: (context, _) {
                  final encendidos = (_animacion.value * 4).floor();
                  return Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Text(
                          '.',
                          style: SfTypography.title.copyWith(
                            color: i < encendidos
                                ? SfColors.primaryLight
                                : SfColors.textDisabled,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
