import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/assistant/domain/formato_respuesta.dart';

/// Texto del asistente con formato: párrafos, lista numerada con el número
/// en un círculo, viñetas y **negrita**.
class FormattedReply extends StatelessWidget {
  const FormattedReply({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final lineas = lineasDeRespuesta(texto);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (indice, linea) in lineas.indexed) ...[
          if (indice > 0) const SizedBox(height: SfSpacing.xs),
          switch (linea.tipo) {
            TipoLinea.parrafo => _Inline(texto: linea.texto),
            TipoLinea.numerada => _Item(
              marca: Container(
                width: SfSpacing.lg,
                height: SfSpacing.lg,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: SfColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${linea.numero}',
                  style: SfTypography.caption.copyWith(
                    color: SfColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              texto: linea.texto,
            ),
            TipoLinea.vineta => _Item(
              marca: SizedBox(
                width: SfSpacing.lg,
                child: Text(
                  '•',
                  textAlign: TextAlign.center,
                  style: SfTypography.body.copyWith(
                    color: SfColors.primaryLight,
                  ),
                ),
              ),
              texto: linea.texto,
            ),
          },
        ],
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.marca, required this.texto});

  final Widget marca;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        marca,
        const SizedBox(width: SfSpacing.xs),
        Expanded(child: _Inline(texto: texto)),
      ],
    );
  }
}

/// Un renglón con sus trozos en **negrita**.
class _Inline extends StatelessWidget {
  const _Inline({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: SfTypography.body,
        children: [
          for (final (trozo, negrita) in trozosConNegrita(texto))
            TextSpan(
              text: trozo,
              style: negrita ? SfTypography.bodyStrong : null,
            ),
        ],
      ),
    );
  }
}
