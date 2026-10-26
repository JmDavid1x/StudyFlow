import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_layout.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_validators.dart';

/// Recuperar contraseña (Figma 06): se pide el correo y se envía un enlace.
/// Pasa el correo a Correo enviado (Figma 07) para mostrarlo allá.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _triedToSubmit = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  String? get _emailError => AuthValidators.email(_email.text);

  void _submit() {
    setState(() => _triedToSubmit = true);
    if (_emailError != null) return;
    // Sprint 2: aquí se pide el enlace a Supabase Auth.
    Navigator.pushReplacementNamed(context, AppRoutes.emailSent, arguments: _email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: true,
      actions: [SfButton(label: 'Enviar enlace', onPressed: _submit)],
      children: [
        const AuthHeading(
          title: 'Recupera tu contraseña',
          subtitle: 'Escribe el correo con el que te registraste y te enviamos un enlace para crear una nueva.',
        ),
        const SizedBox(height: SfSpacing.lg),
        SfTextField(
          label: 'Correo institucional',
          hint: 'nombre@u.icesi.edu.co',
          icon: Icons.mail_outline,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.send,
          autofillHints: const [AutofillHints.email],
          errorText: _triedToSubmit ? _emailError : null,
          onChanged: (_) {
            if (_triedToSubmit) setState(() {});
          },
          onSubmitted: (_) => _submit(),
        ),
      ],
    );
  }
}
