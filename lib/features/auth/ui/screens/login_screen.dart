import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/auth/domain/auth_validators.dart';
import 'package:studyflow/features/auth/ui/bloc/auth_bloc.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_layout.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_messages.dart';
import 'package:studyflow/features/auth/ui/widgets/brand_mark.dart';

/// Iniciar sesión (Figma 05) con Supabase Auth. Si entra bien, va a la
/// pestaña Inicio (o a la configuración inicial si no la terminó) y borra el
/// historial, para que el botón atrás no regrese al login.
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
    // Evita mandar el formulario dos veces (botón + Enter del teclado).
    if (context.read<AuthBloc>().state.cargando(AccionAuth.inicioSesion)) return;
    setState(() => _triedToSubmit = true);
    if (_emailError != null || _passwordError != null) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(InicioSesionPedido(correo: _email.text, contrasena: _password.text));
  }

  void _onState(BuildContext context, AuthState state) {
    if (state.error(AccionAuth.inicioSesion)) {
      showAuthError(context, state.mensaje);
    } else if (state.exito(AccionAuth.inicioSesion)) {
      // Si no terminó la configuración inicial, la retoma (Figma 08). Si el
      // perfil no cargó (red), entra a la app y cada pestaña reintenta.
      final configurado = state.perfil?.configuracionCompleta ?? true;
      Navigator.pushNamedAndRemoveUntil(
        context,
        configurado ? AppRoutes.main : AppRoutes.setupSubjects,
        (_) => false,
        arguments: configurado ? AppTabs.home : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select((AuthBloc bloc) => bloc.state.cargando(AccionAuth.inicioSesion));

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (before, now) => now.accion == AccionAuth.inicioSesion && before.estado != now.estado,
      listener: _onState,
      child: _buildForm(loading),
    );
  }

  Widget _buildForm(bool loading) {
    return AuthLayout(
      actions: [
        SfButton(label: 'Entrar', isLoading: loading, onPressed: loading ? null : _submit),
        const SizedBox(height: SfSpacing.xxs),
        SfButton(
          label: '¿No tienes cuenta? Crea una',
          variant: SfButtonVariant.ghost,
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.register),
        ),
      ],
      children: [
        const SizedBox(height: SfSpacing.lg),
        // En modo debug, dejar presionado el logo abre el menú de desarrollo.
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onLongPress: kDebugMode ? () => Navigator.pushNamed(context, AppRoutes.devMenu) : null,
            child: const BrandMark(),
          ),
        ),
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
