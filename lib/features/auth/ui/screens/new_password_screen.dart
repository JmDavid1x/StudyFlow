import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/auth/domain/auth_validators.dart';
import 'package:studyflow/features/auth/ui/bloc/auth_bloc.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_layout.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_messages.dart';

/// Contraseña nueva. Se abre sola cuando el usuario toca el enlace del correo
/// de recuperación: Supabase avisa con el evento passwordRecovery y app.dart
/// trae esta pantalla. Al guardar, entra a la app.
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _triedToSubmit = false;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  String? get _passwordError => AuthValidators.newPassword(_password.text);
  String? get _confirmationError =>
      _confirmation.text == _password.text ? null : 'Las contraseñas no coinciden';

  void _refresh(String _) {
    if (_triedToSubmit) setState(() {});
  }

  void _submit() {
    if (context.read<AuthBloc>().state.cargando(AccionAuth.cambioContrasena)) return;
    setState(() => _triedToSubmit = true);
    if (_passwordError != null || _confirmationError != null) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(CambioContrasenaPedido(nueva: _password.text, confirmacion: _confirmation.text));
  }

  void _onState(BuildContext context, AuthState state) {
    if (state.error(AccionAuth.cambioContrasena)) {
      showAuthError(context, state.mensaje);
    } else if (state.exito(AccionAuth.cambioContrasena)) {
      showAuthInfo(context, 'Listo, ya tienes una contraseña nueva.');
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false, arguments: AppTabs.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select((AuthBloc bloc) => bloc.state.cargando(AccionAuth.cambioContrasena));
    final passwordError = _triedToSubmit ? _passwordError : null;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (before, now) => now.accion == AccionAuth.cambioContrasena && before.estado != now.estado,
      listener: _onState,
      child: AuthLayout(
        actions: [SfButton(label: 'Guardar contraseña', isLoading: loading, onPressed: loading ? null : _submit)],
        children: [
          const AuthHeading(title: 'Crea una contraseña nueva', subtitle: 'Úsala la próxima vez que inicies sesión.'),
          const SizedBox(height: SfSpacing.lg),
          SfTextField(
            label: 'Contraseña nueva',
            hint: 'Mínimo 8 caracteres',
            icon: Icons.lock_outline,
            controller: _password,
            isPassword: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            errorText: passwordError,
            onChanged: _refresh,
          ),
          if (passwordError == null) const AuthFieldNote('Mínimo 8 caracteres, con al menos un número.'),
          const SizedBox(height: SfSpacing.md),
          SfTextField(
            label: 'Repite la contraseña',
            hint: 'Escríbela otra vez',
            icon: Icons.lock_outline,
            controller: _confirmation,
            isPassword: true,
            textInputAction: TextInputAction.done,
            errorText: _triedToSubmit ? _confirmationError : null,
            onChanged: _refresh,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
    );
  }
}
