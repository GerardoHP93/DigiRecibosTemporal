import 'package:flutter/material.dart';
import 'package:digirecibos/services/auth_service.dart';
import 'package:digirecibos/features/auth/screens/email_verification_screen.dart';
import 'package:digirecibos/features/auth/widgets/auth_background.dart';
import 'package:digirecibos/features/auth/widgets/auth_card.dart';
import 'package:digirecibos/features/auth/widgets/auth_button.dart';
import 'package:digirecibos/features/auth/widgets/auth_text_field.dart';
import 'package:digirecibos/features/auth/widgets/password_field.dart';
import 'package:digirecibos/features/auth/widgets/auth_title.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService authService = AuthService();
  bool _isLoading = false;

  // Validación de formulario
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre de usuario es obligatorio';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    // Validación básica de formato de email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La contraseña es obligatoria';
    }
    // Expresión regular que valida:
    // - Mínimo 8 caracteres
    // - Al menos una mayúscula
    // - Al menos una minúscula
    // - Al menos un número
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$');
    if (!passwordRegex.hasMatch(value)) {
      return 'La contraseña debe tener mínimo 8 caracteres, mayúsculas, minúsculas y números';
    }
    return null; // La contraseña es válida
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Debes confirmar la contraseña';
    }
    if (value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // Validar todos los campos antes de enviar
  bool _validateForm() {
    bool isValid = true;
    // Validar todos los campos
    final usernameError = _validateUsername(usernameController.text);
    final emailError = _validateEmail(emailController.text);
    final passwordError = _validatePassword(passwordController.text);
    final confirmPasswordError = _validateConfirmPassword(confirmPasswordController.text);

    if (usernameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      // Mostrar el primer error encontrado
      String errorMessage = usernameError ??
          emailError ??
          passwordError ??
          confirmPasswordError ??
          'Por favor completa todos los campos correctamente';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    return isValid;
  }

  void register() async {
    // Validar el formulario antes de proceder
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await authService.registerUser(
      emailController.text.trim(),
      passwordController.text,
      usernameController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // Redirigir a la pantalla de verificación de correo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationScreen(
            email: emailController.text.trim(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      backgroundColor: AppColors.primaryLight,
      child: SafeArea(
        child: AuthCard(
          minHeight: 550,
          maxHeight: 680,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título
              const AuthTitle(title: "CREAR UNA CUENTA"),
              const SizedBox(height: AppDimens.paddingXL),
              
              // Campo de correo
              AuthTextField(
                controller: emailController,
                labelText: "Ingresa tu correo",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimens.paddingL),
              
              // Campo de nombre de usuario
              AuthTextField(
                controller: usernameController,
                labelText: "Ingresa tu nombre",
              ),
              const SizedBox(height: AppDimens.paddingL),
              
              // Campo de contraseña
              PasswordField(
                controller: passwordController,
                labelText: "Ingresa una contraseña",
                helperText: "Mínimo 8 caracteres, con mayúsculas y números",
              ),
              const SizedBox(height: AppDimens.paddingL),
              
              // Campo de confirmar contraseña
              PasswordField(
                controller: confirmPasswordController,
                labelText: "Confirma tu contraseña",
              ),
              const SizedBox(height: AppDimens.paddingXL),
              
              // Botón de crear cuenta
              AuthButton(
                text: "Crear cuenta",
                isLoading: _isLoading,
                onPressed: register,
              ),
              const SizedBox(height: AppDimens.paddingL),
              
              // Botón de ya tengo una cuenta
              AuthButton(
                text: "Ya tengo una cuenta",
                onPressed: () {
                  Navigator.pop(context);
                },
                type: AuthButtonType.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}