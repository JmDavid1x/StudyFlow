import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_layout.dart';
import 'package:studyflow/features/auth/ui/widgets/auth_validators.dart';
import 'package:studyflow/features/auth/ui/widgets/university_sheet.dart';

/// Registro (Figma 04): nombre, correo institucional, contraseña y
/// universidad. Los errores aparecen después del primer intento y se
/// actualizan mientras se escribe. Al crear la cuenta empieza la
/// configuración inicial (Figma 08).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _university;

  /// Los errores solo se muestran después de tocar "Crear cuenta".
  bool _triedToSubmit = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _show(String? error) => _triedToSubmit ? error : null;

  String? get _nameError => AuthValidators.name(_name.text);
  String? get _emailError => AuthValidators.email(_email.text);
  String? get _passwordError => AuthValidators.newPassword(_password.text);
  String? get _universityError => _university == null ? 'Elige tu universidad' : null;

  void _refresh(String _) {
    if (_triedToSubmit) setState(() {});
  }

  Future<void> _pickUniversity() async {
    final picked = await showUniversitySheet(context, selected: _university);
    if (picked != null) setState(() => _university = picked);
  }

  void _submit() {
    setState(() => _triedToSubmit = true);
    final hasErrors = [_nameError, _emailError, _passwordError, _universityError].any((e) => e != null);
    if (hasErrors) return;
    // Sprint 2: aquí se crea la cuenta en Supabase Auth y el perfil.
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.setupSubjects, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final passwordError = _show(_passwordError);
    final universityError = _show(_universityError);

    return AuthLayout(
      showBack: true,
      actions: [
        SfButton(label: 'Crear cuenta', onPressed: _submit),
        const SizedBox(height: SfSpacing.xxs),
        SfButton(
          label: '¿Ya tienes cuenta? Inicia sesión',
          variant: SfButtonVariant.ghost,
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
        ),
      ],
      children: [
        const AuthHeading(title: 'Crea tu cuenta', subtitle: 'Usa tu correo de la universidad.'),
        const SizedBox(height: SfSpacing.lg),
        SfTextField(
          label: 'Nombre',
          hint: 'Tu nombre completo',
          icon: Icons.person_outline,
          controller: _name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          errorText: _show(_nameError),
          onChanged: _refresh,
        ),
        const SizedBox(height: SfSpacing.md),
        SfTextField(
          label: 'Correo institucional',
          hint: 'nombre@u.icesi.edu.co',
          icon: Icons.mail_outline,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: _show(_emailError),
          onChanged: _refresh,
        ),
        const SizedBox(height: SfSpacing.md),
        SfTextField(
          label: 'Contraseña',
          hint: 'Crea una contraseña',
          icon: Icons.lock_outline,
          controller: _password,
          isPassword: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          errorText: passwordError,
          onChanged: _refresh,
        ),
        if (passwordError == null)
          const AuthFieldNote('Mínimo 8 caracteres, con al menos un número.'),
        const SizedBox(height: SfSpacing.md),
        SfPickerField(
          label: 'Universidad',
          icon: Icons.school_outlined,
          value: _university,
          placeholder: 'Elige tu universidad',
          onTap: _pickUniversity,
        ),
        if (universityError != null) AuthFieldNote(universityError, isError: true),
      ],
    );
  }
}
