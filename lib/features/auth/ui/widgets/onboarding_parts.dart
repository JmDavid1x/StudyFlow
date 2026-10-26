import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/auth/ui/widgets/brand_mark.dart';

/// Una página del onboarding: ilustración, título y mensaje.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.illustration,
    required this.title,
    required this.message,
  });

  final Widget illustration;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          illustration,
          const SizedBox(height: SfSpacing.xl),
          Text(title, style: SfTypography.display),
          const SizedBox(height: SfSpacing.sm),
          Text(message, style: SfTypography.body.copyWith(color: SfColors.textSecondary)),
        ],
      ),
    );
  }
}

/// Página 1 (Figma 02): lo que llega por correo, WhatsApp e INTU termina
/// junto en StudyFlow.
class SourcesIllustration extends StatelessWidget {
  const SourcesIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SfCard(
      child: Column(
        children: [
          OnboardingRow(icon: Icons.mail_outline, title: 'Correo', subtitle: '“El taller 3 se entrega el lunes”'),
          SizedBox(height: SfSpacing.xs),
          OnboardingRow(icon: Icons.send_outlined, title: 'WhatsApp', subtitle: '“Profe dijo: parcial el jueves”'),
          SizedBox(height: SfSpacing.xs),
          OnboardingRow(icon: Icons.school_outlined, title: 'INTU', subtitle: 'Proyecto final · 40 %'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: SfSpacing.xs),
            child: Icon(Icons.arrow_downward_rounded, color: SfColors.textSecondary),
          ),
          OnboardingRow(
            brand: true,
            title: 'StudyFlow',
            subtitle: '3 entregas y 1 parcial esta semana',
          ),
        ],
      ),
    );
  }
}

/// Página 2 (Figma 03): avisos a tiempo y un orden sugerido para estudiar.
class RemindersIllustration extends StatelessWidget {
  const RemindersIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingRow(
            icon: Icons.notifications_none_rounded,
            title: 'Mañana vence',
            subtitle: 'Prototipo flujo principal · 11:59 p. m.',
          ),
          const SizedBox(height: SfSpacing.xs),
          const OnboardingRow(
            icon: Icons.schedule,
            title: 'En 15 minutos',
            subtitle: 'Bloque de estudio para el Parcial 2',
          ),
          const SizedBox(height: SfSpacing.md),
          Text('Tu orden sugerido', style: SfTypography.label),
          const SizedBox(height: SfSpacing.xs),
          const _OrderRow(position: 1, title: 'Lectura capítulo 4', color: SfColors.warning),
          const _OrderRow(position: 2, title: 'Taller 3: consultas SQL', color: SfColors.info),
          const _OrderRow(position: 3, title: 'Prototipo flujo principal', color: SfColors.primaryLight),
        ],
      ),
    );
  }
}

/// Fila de la ilustración: ícono, título y una línea de detalle. Con [brand]
/// se destaca como StudyFlow.
class OnboardingRow extends StatelessWidget {
  const OnboardingRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.brand = false,
  });

  final IconData? icon;
  final String title;
  final String subtitle;
  final bool brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SfSpacing.sm),
      decoration: BoxDecoration(
        color: brand ? SfColors.primarySoft : SfColors.background,
        borderRadius: BorderRadius.circular(SfRadius.md),
        border: Border.all(color: brand ? SfColors.primary : SfColors.border),
      ),
      child: Row(
        children: [
          if (brand)
            const BrandMark(size: SfSpacing.xl + SfSpacing.xxs)
          else
            Container(
              width: SfSpacing.xl + SfSpacing.xxs,
              height: SfSpacing.xl + SfSpacing.xxs,
              decoration: const BoxDecoration(color: SfColors.primarySoft, shape: BoxShape.circle),
              child: Icon(icon, size: SfSpacing.md + SfSpacing.xxs, color: SfColors.primaryLight),
            ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SfTypography.bodyStrong),
                Text(subtitle, style: SfTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.position, required this.title, required this.color});

  final int position;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SfSpacing.xxs),
      child: Row(
        children: [
          Container(
            width: SfSpacing.lg,
            height: SfSpacing.lg,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Text('$position', style: SfTypography.caption.copyWith(color: color)),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(child: Text(title, style: SfTypography.body)),
        ],
      ),
    );
  }
}

/// Indicador de páginas: la actual es una barra, las demás un punto.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Página ${current + 1} de $count',
      child: Row(
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(right: SfSpacing.xs),
              width: i == current ? SfSpacing.xl - SfSpacing.xxs : SfSpacing.xs,
              height: SfSpacing.xs,
              decoration: BoxDecoration(
                color: i == current ? SfColors.primary : SfColors.borderStrong,
                borderRadius: BorderRadius.circular(SfRadius.sm),
              ),
            ),
        ],
      ),
    );
  }
}
