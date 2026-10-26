import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/assistant/ui/widgets/assistant_demo.dart';
import 'package:studyflow/features/assistant/ui/widgets/chat_bubble.dart';
import 'package:studyflow/features/assistant/ui/widgets/offline_notice.dart';
import 'package:studyflow/features/assistant/ui/widgets/plan_added_sheet.dart';
import 'package:studyflow/features/assistant/ui/widgets/suggested_order_card.dart';

/// Asistente (Figma 24) y su estado sin conexión (Figma 31).
///
/// Sprint 1: no hay IA real. Al enviar una pregunta se simula que la IA no
/// respondió (31); "Reintentar" muestra la respuesta fija con el orden
/// sugerido (24).
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _messages = <ChatMessage>[...AssistantDemo.firstMessages];
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    final question = text.trim();
    if (question.isEmpty) return;
    _input.clear();
    setState(() {
      _messages
        ..add(ChatMessage(author: ChatAuthor.user, text: question))
        ..add(AssistantDemo.offlineMessage);
    });
    _scrollToEnd();
  }

  void _retry() {
    setState(() {
      _messages
        ..removeLast()
        ..add(AssistantDemo.retryMessage);
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SfScreenHeader(
              title: 'Asistente',
              trailing: _FreeCounter(
                onTap: () => Navigator.pushNamed(context, AppRoutes.plus),
              ),
            ),
            Expanded(
              child: _messages.isEmpty
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.screen),
                      child: SfEmptyState(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Pregúntale al asistente',
                        message: 'Escribe una pregunta o toca una sugerencia para armar tu orden de estudio.',
                        actionLabel: AssistantDemo.suggestions.first,
                        onAction: () => _send(AssistantDemo.suggestions.first),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(
                        SfSpacing.screen,
                        SfSpacing.xs,
                        SfSpacing.screen,
                        SfSpacing.md,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => _buildMessage(
                        _messages[index],
                        isLast: index == _messages.length - 1,
                      ),
                    ),
            ),
            _SuggestionBar(onSelected: _send),
            _Composer(controller: _input, onSend: () => _send(_input.text)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, {required bool isLast}) {
    final attachment = switch (message.attachment) {
      ChatAttachment.none => null,
      ChatAttachment.suggestedOrder => SuggestedOrderCard(
          steps: AssistantDemo.suggestedOrder,
          onAddToCalendar: isLast ? () => showPlanAddedSheet(context, AssistantDemo.suggestedOrder) : null,
        ),
      ChatAttachment.offline => OfflineNotice(
          fallback: AssistantDemo.fallbackOrder,
          onRetry: isLast ? _retry : null,
          onAddToCalendar: isLast
              ? () => showPlanAddedSheet(context, AssistantDemo.planFor(AssistantDemo.fallbackOrder))
              : null,
        ),
    };
    return ChatBubble(text: message.text, isUser: message.isUser, child: attachment);
  }
}

/// "3 de 5 gratis". Lleva a StudyFlow Plus.
class _FreeCounter extends StatelessWidget {
  const _FreeCounter({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Consultas gratis, ver StudyFlow Plus',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SfRadius.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: const Center(
            child: SfBadge(
              label: '${AssistantDemo.freeUsed} de ${AssistantDemo.freeLimit} gratis',
              tone: SfTone.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Chips de preguntas sugeridas encima del campo de escribir.
class _SuggestionBar extends StatelessWidget {
  const _SuggestionBar({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.screen),
      child: Row(
        children: [
          for (final suggestion in AssistantDemo.suggestions) ...[
            SfChip(label: suggestion, onTap: () => onSelected(suggestion)),
            const SizedBox(width: SfSpacing.xs),
          ],
        ],
      ),
    );
  }
}

/// Campo para escribir y botón de enviar. Sube con el teclado porque el
/// Scaffold redimensiona el cuerpo.
class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.sm, SfSpacing.screen, SfSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: SfTextField(
              controller: controller,
              hint: 'Escribe tu pregunta',
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: SfSpacing.xs),
          SfIconButton(
            icon: Icons.send_rounded,
            tooltip: 'Enviar',
            filled: true,
            size: SfSpacing.xxl,
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
