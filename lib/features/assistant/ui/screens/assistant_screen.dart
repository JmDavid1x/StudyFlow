import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/assistant/ui/bloc/assistant_bloc.dart';
import 'package:studyflow/features/assistant/ui/widgets/chat_bubble.dart';
import 'package:studyflow/features/assistant/ui/widgets/offline_notice.dart';
import 'package:studyflow/features/assistant/ui/widgets/plan_added_sheet.dart';
import 'package:studyflow/features/assistant/ui/widgets/suggested_order_card.dart';

/// Preguntas sugeridas encima del campo de escribir.
const _sugerencias = <String>[
  '¿Qué hago hoy?',
  'Organiza mi semana',
  '¿Qué entrego primero?',
];

/// Asistente (Figma 24) y su estado sin conexión (Figma 31). El Bloc se
/// crea en assistant_routes.dart.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    _input.clear();
    context.read<AssistantBloc>().add(PreguntaEnviada(text));
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

  /// Abre Plus y, al volver, recarga (pudo empezar la prueba).
  Future<void> _openPlus() async {
    final bloc = context.read<AssistantBloc>();
    await Navigator.pushNamed(context, AppRoutes.plus);
    // Si inició la prueba, S11 cerró esta pantalla y abrió otro asistente.
    if (mounted) bloc.add(const AsistenteIniciado());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Mensaje nuevo: baja hasta el final del chat.
        BlocListener<AssistantBloc, AssistantState>(
          listenWhen: (antes, ahora) =>
              antes.mensajes.length != ahora.mensajes.length,
          listener: (context, state) => _scrollToEnd(),
        ),
        // Error de una acción: SnackBar.
        BlocListener<AssistantBloc, AssistantState>(
          listenWhen: (antes, ahora) => antes.avisoId != ahora.avisoId,
          listener: (context, state) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.aviso!))),
        ),
        // Plan creado: hoja S4.
        BlocListener<AssistantBloc, AssistantState>(
          listenWhen: (antes, ahora) => antes.planId != ahora.planId,
          listener: (context, state) =>
              showPlanAddedSheet(context, state.planAgregado!),
        ),
      ],
      child: BlocBuilder<AssistantBloc, AssistantState>(builder: _buildScreen),
    );
  }

  Widget _buildScreen(BuildContext context, AssistantState state) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SfScreenHeader(
              title: 'Asistente',
              trailing: _FreeCounter(
                label: state.limite.etiqueta,
                onTap: _openPlus,
              ),
            ),
            Expanded(child: _buildBody(context, state)),
            if (state.enviando)
              Padding(
                padding: const EdgeInsets.only(bottom: SfSpacing.xs),
                child: Text(
                  'El asistente está revisando tus pendientes…',
                  style: SfTypography.caption.copyWith(
                    color: SfColors.textSecondary,
                  ),
                ),
              ),
            _SuggestionBar(
              onSelected:
                  state.estado == EstadoAsistente.listo && !state.enviando
                  ? _send
                  : null,
            ),
            _Composer(
              controller: _input,
              onSend: state.estado == EstadoAsistente.listo && !state.enviando
                  ? () => _send(_input.text)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AssistantState state) {
    switch (state.estado) {
      case EstadoAsistente.cargando:
        return const Center(
          child: SfLoadingState(message: 'Cargando tu conversación'),
        );
      case EstadoAsistente.error:
        return Center(
          child: SingleChildScrollView(
            child: SfErrorState(
              message: state.mensaje ?? 'No pudimos cargar el chat.',
              onRetry: () =>
                  context.read<AssistantBloc>().add(const AsistenteIniciado()),
            ),
          ),
        );
      case EstadoAsistente.listo:
        if (state.mensajes.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: SfSpacing.screen),
            child: SfEmptyState(
              icon: Icons.auto_awesome_outlined,
              title: 'Pregúntale al asistente',
              message:
                  'Escribe una pregunta o toca una sugerencia para armar tu orden de estudio.',
              actionLabel: _sugerencias.first,
              onAction: () => _send(_sugerencias.first),
            ),
          );
        }
        return ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(
            SfSpacing.screen,
            SfSpacing.xs,
            SfSpacing.screen,
            SfSpacing.md,
          ),
          itemCount: state.mensajes.length,
          itemBuilder: (context, index) =>
              _buildMessage(context, state, state.mensajes[index]),
        );
    }
  }

  Widget _buildMessage(
    BuildContext context,
    AssistantState state,
    MensajeAsistente mensaje,
  ) {
    final orden = state.orden;
    final conOrden = orden != null && mensaje.id == state.respuestaId;
    if (!conOrden) {
      return ChatBubble(
        text: mensaje.contenido,
        isUser: mensaje.rol == RolMensaje.usuario,
      );
    }

    final bloc = context.read<AssistantBloc>();
    // La lista ya va en la tarjeta: en la burbuja solo la primera línea.
    final texto = mensaje.contenido.split('\n').first;
    final Widget tarjeta = mensaje.usadoRespaldo
        ? OfflineNotice(
            orden: orden,
            ocupado: state.enviando || state.agregando,
            onRetry: () => bloc.add(const ReintentoPedido()),
            onAddToCalendar: () => bloc.add(const PlanPedido()),
          )
        : SuggestedOrderCard(
            orden: orden,
            agregando: state.agregando,
            onAddToCalendar: () => bloc.add(const PlanPedido()),
          );
    return ChatBubble(text: texto, isUser: false, child: tarjeta);
  }
}

/// "3 de 5 gratis" o "Plus". Lleva a StudyFlow Plus.
class _FreeCounter extends StatelessWidget {
  const _FreeCounter({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Consultas: $label. Ver StudyFlow Plus',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SfRadius.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Center(
            child: SfBadge(label: label, tone: SfTone.primary),
          ),
        ),
      ),
    );
  }
}

/// Chips de preguntas sugeridas encima del campo de escribir.
class _SuggestionBar extends StatelessWidget {
  const _SuggestionBar({required this.onSelected});

  /// Nulo mientras se espera una respuesta.
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.screen),
      child: Row(
        children: [
          for (final sugerencia in _sugerencias) ...[
            SfChip(
              label: sugerencia,
              onTap: onSelected == null ? null : () => onSelected!(sugerencia),
            ),
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

  /// Nulo mientras se espera una respuesta.
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SfSpacing.screen,
        SfSpacing.sm,
        SfSpacing.screen,
        SfSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: SfTextField(
              controller: controller,
              hint: 'Escribe tu pregunta',
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              onSubmitted: onSend == null ? null : (_) => onSend!(),
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
