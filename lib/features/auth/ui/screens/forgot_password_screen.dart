import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/auth/domain/auth_validators.dart';
import 'package:studyflow/features/auth/ui/bloc/auth_bloc.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_layout.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_messages.dart';

/// Recuperar contraseña (Figma 06): Supabase Auth manda al correo un enlace
/// para crear una nueva. Pasa el correo a Correo enviado (Figma 07).
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
    if (context.read<AuthBloc>().state.cargando(AccionAuth.recuperacion)) return;
    setState(() => _triedToSubmit = true);
    if (_emailError != null) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(RecuperacionPedida(_email.text));
  }

  void _onState(BuildContext context, AuthState state) {
    if (state.error(AccionAuth.recuperacion)) {
      showAuthError(context, state.mensaje);
    } else if (state.exito(AccionAuth.recuperacion)) {
      Navigator.pushReplacementNamed(context, AppRoutes.emailSent, arguments: state.correoEnviado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select((AuthBloc bloc) => bloc.state.cargando(AccionAuth.recuperacion));

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (before, now) => now.accion == AccionAuth.recuperacion && before.estado != now.estado,
      listener: _onState,
      child: _buildForm(loading),
    );
  }

  Widget _buildForm(bool loading) {
    return AuthLayout(
      showBack: true,
      actions: [SfButton(label: 'Enviar enlace', isLoading: loading, onPressed: loading ? null : _submit)],
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
