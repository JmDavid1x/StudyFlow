import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_layout.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_validators.dart';
import 'package:studyflow/features/auth/ui/widgets/brand_mark.dart';

/// Iniciar sesión (Figma 05): correo institucional y contraseña. "Entrar"
/// lleva a la pestaña Inicio y borra el historial, para que el botón atrás
/// no regrese al login.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  /// Los errores solo se muestran después de tocar "Entrar".
  bool _triedToSubmit = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? get _emailError => AuthValidators.email(_email.text);
  String? get _passwordError => AuthValidators.password(_password.text);

  void _refresh(String _) {
    if (_triedToSubmit) setState(() {});
  }

  void _submit() {
    setState(() => _triedToSubmit = true);
    if (_emailError != null || _passwordError != null) return;
    // Sprint 2: aquí se inicia sesión con Supabase Auth.
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false, arguments: AppTabs.home);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      actions: [
        SfButton(label: 'Entrar', onPressed: _submit),
        const SizedBox(height: SfSpacing.xxs),
        SfButton(
          label: '¿No tienes cuenta? Crea una',
          variant: SfButtonVariant.ghost,
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.register),
        ),
      ],
      children: [
        const SizedBox(height: SfSpacing.lg),
        const Align(alignment: Alignment.centerLeft, child: BrandMark()),
        const SizedBox(height: SfSpacing.lg),
        const AuthHeading(title: 'Hola de nuevo', subtitle: 'Inicia sesión para ver tus entregas.'),
        const SizedBox(height: SfSpacing.lg),
        SfTextField(
          label: 'Correo institucional',
          hint: 'nombre@u.icesi.edu.co',
          icon: Icons.mail_outline,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: _triedToSubmit ? _emailError : null,
          onChanged: _refresh,
        ),
        const SizedBox(height: SfSpacing.md),
        SfTextField(
          label: 'Contraseña',
          hint: 'Tu contraseña',
          icon: Icons.lock_outline,
          controller: _password,
          isPassword: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          errorText: _triedToSubmit ? _passwordError : null,
          onChanged: _refresh,
          onSubmitted: (_) => _submit(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SfButton(
            label: '¿Olvidaste tu contraseña?',
            variant: SfButtonVariant.ghost,
            expand: false,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
          ),
        ),
      ],
    );
  }
}
