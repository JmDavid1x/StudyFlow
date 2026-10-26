import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Burbuja del chat. Las del usuario van a la derecha en violeta y las del
/// asistente a la izquierda en superficie. [child] va debajo del texto (la
/// tarjeta del orden sugerido o el aviso sin conexión).
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.text, required this.isUser, this.child});

  final String text;
  final bool isUser;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    const corner = Radius.circular(SfRadius.lg);
    const tail = Radius.circular(SfRadius.sm);
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.md, vertical: SfSpacing.sm),
      decoration: BoxDecoration(
        color: isUser ? SfColors.primary : SfColors.surface,
        border: isUser ? null : Border.all(color: SfColors.border),
        borderRadius: BorderRadius.only(
          topLeft: corner,
          topRight: corner,
          bottomLeft: isUser ? corner : tail,
          bottomRight: isUser ? tail : corner,
        ),
      ),
      child: Text(text, style: SfTypography.body),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: SfSpacing.sm),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          FractionallySizedBox(
            widthFactor: 0.82,
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: bubble,
            ),
          ),
          if (child != null) ...[
            const SizedBox(height: SfSpacing.xs),
            child!,
          ],
        ],
      ),
    );
  }
}
