import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/navigation/screen_catalog.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';

/// Índice de todas las pantallas, agrupadas por quién las construye. Solo
/// para desarrollo: permite abrir cualquier pantalla sin recorrer el flujo
/// y cargar los datos de ejemplo del prototipo en la cuenta con sesión.
/// Se abre dejando presionado el logo del login (solo en modo debug).
class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final owners = <String>[];
    for (final screen in screenCatalog) {
      if (!owners.contains(screen.owner)) owners.add(screen.owner);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Menú de desarrollo'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.xxl),
                children: [
                  const _SampleDataButton(),
                  const SizedBox(height: SfSpacing.xs),
                  SfButton(
                    label: 'Ver el design system',
                    icon: Icons.palette_outlined,
                    variant: SfButtonVariant.secondary,
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.designSystem),
                  ),
                  for (final owner in owners) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: SfSpacing.lg, bottom: SfSpacing.xs),
                      child: Text(owner, style: SfTypography.h2),
                    ),
                    for (final screen in screenCatalog.where((s) => s.owner == owner))
                      _ScreenRow(screen: screen),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenRow extends StatelessWidget {
  const _ScreenRow({required this.screen});

  final ScreenInfo screen;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 72,
        child: Text(screen.figma, style: SfTypography.number.copyWith(color: SfColors.primaryLight)),
      ),
      title: Text(screen.title, style: SfTypography.body),
      trailing: const Icon(Icons.chevron_right, color: SfColors.textSecondary),
      onTap: () => Navigator.pushNamed(context, screen.route, arguments: screen.tab),
    );
  }
}

/// Llama a la función `cargar_datos_ejemplo` de la base: crea el semestre del
/// prototipo (materias, tareas, bloques, notificaciones) para quien tenga
/// sesión. Si ya tiene un semestre activo, no hace nada.
class _SampleDataButton extends StatefulWidget {
  const _SampleDataButton();

  @override
  State<_SampleDataButton> createState() => _SampleDataButtonState();
}

class _SampleDataButtonState extends State<_SampleDataButton> {
  bool _loading = false;

  Future<void> _load() async {
    final messenger = ScaffoldMessenger.of(context);
    if (supabase.auth.currentUser == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Primero inicia sesión.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await supabase.rpc<void>('cargar_datos_ejemplo');
      messenger.showSnackBar(
        const SnackBar(content: Text('Listo: datos de ejemplo cargados (si ya tenías un semestre, no cambió nada).')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfButton(
      label: 'Cargar datos de ejemplo',
      icon: Icons.dataset_outlined,
      isLoading: _loading,
      onPressed: _load,
    );
  }
}
