import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/core/realtime/cambios_en_vivo.dart';

/// Envuelve una pantalla y llama [alCambiar] cuando cambian sus [tablas] en
/// Supabase. Mientras la pantalla existe, la suscripción sigue abierta; al
/// salir se cierra sola.
///
/// ```dart
/// RecargarEnVivo(
///   tablas: const {'actividades', 'bloques_estudio'},
///   alCambiar: () => context.read<HomeCubit>().cargar(),
///   child: ...,
/// )
/// ```
class RecargarEnVivo extends StatefulWidget {
  const RecargarEnVivo({
    super.key,
    required this.tablas,
    required this.alCambiar,
    required this.child,
    this.cambios,
  });

  final Set<String> tablas;
  final VoidCallback alCambiar;
  final Widget child;

  /// Para los tests; si es null lo pide a GetIt (Supabase Realtime).
  final CambiosEnVivo? cambios;

  @override
  State<RecargarEnVivo> createState() => _RecargarEnVivoState();
}

class _RecargarEnVivoState extends State<RecargarEnVivo> {
  StreamSubscription<void>? _suscripcion;

  @override
  void initState() {
    super.initState();
    final cambios = widget.cambios ?? sl<CambiosEnVivo>();
    _suscripcion = cambios.de(widget.tablas).listen(
          (_) => widget.alCambiar(),
          // Sin conexión en vivo la app sigue funcionando con recargas normales.
          onError: (Object _) {},
        );
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
