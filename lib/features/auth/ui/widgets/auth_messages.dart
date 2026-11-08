import 'package:flutter/material.dart';

/// Muestra abajo el error que mandó el AuthBloc (ya viene en español).
void showAuthError(BuildContext context, String? message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message ?? 'Algo salió mal. Intenta de nuevo.')));
}

/// Mensaje informativo (por ejemplo, "Te enviamos un correo").
void showAuthInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
