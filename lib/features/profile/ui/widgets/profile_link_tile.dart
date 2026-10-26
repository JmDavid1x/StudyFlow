import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Fila de acceso del perfil: ícono, texto, ayuda y flecha.
class ProfileLinkTile extends StatelessWidget {
  const ProfileLinkTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.md, vertical: SfSpacing.sm),
      child: Row(
        children: [
          Container(
            width: SfSpacing.xxl - SfSpacing.xs,
            height: SfSpacing.xxl - SfSpacing.xs,
            decoration: BoxDecoration(
              color: SfColors.primarySoft,
              borderRadius: BorderRadius.circular(SfRadius.md),
            ),
            child: Icon(icon, color: SfColors.primaryLight),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SfTypography.bodyStrong),
                Text(subtitle, style: SfTypography.caption.copyWith(color: SfColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: SfColors.textSecondary),
        ],
      ),
    );
  }
}
