// lib/features/auth/screens/register_screen.dart - Versión corregida

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
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthService authService = AuthService();
  bool _isLoading = false;
  bool _termsAccepted = false;

  // Métodos de validación... (sin cambios)
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
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La contraseña es obligatoria';
    }
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$');
    if (!passwordRegex.hasMatch(value)) {
      return 'La contraseña debe tener mínimo 8 caracteres, mayúsculas, minúsculas y números';
    }
    return null;
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

  bool _validateForm() {
    bool isValid = true;
    final usernameError = _validateUsername(usernameController.text);
    final emailError = _validateEmail(emailController.text);
    final passwordError = _validatePassword(passwordController.text);
    final confirmPasswordError =
        _validateConfirmPassword(confirmPasswordController.text);

    if (usernameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
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

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Debes aceptar los términos y condiciones para continuar'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }

    return isValid;
  }

  void register() async {
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

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'TÉRMINOS Y CONDICIONES DE USO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Al utilizar la aplicación DigiRecibos, usted acepta los siguientes términos y condiciones:',
              ),
              SizedBox(height: 10),
              Text(
                '1. La aplicación permite almacenar y organizar recibos digitales.\n'
                '2. Sus datos personales serán tratados de acuerdo a nuestra política de privacidad.\n'
                '3. Usted es responsable de mantener la seguridad de su cuenta.\n'
                '4. No nos hacemos responsables por la pérdida de datos.\n'
                '5. Nos reservamos el derecho de modificar o discontinuar el servicio en cualquier momento.\n'
                '6. El uso indebido de la aplicación puede resultar en la suspensión de su cuenta.\n'
                '7. Los archivos subidos deben respetar las leyes de propiedad intelectual.\n'
                '8. La aplicación se proporciona "tal cual" sin garantías de ningún tipo.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener factor de escala de texto para adaptar espaciados
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    // Calcular espaciado adaptativo
    final double verticalSpacing = textScaleFactor > 1.3 
        ? AppDimens.paddingS 
        : AppDimens.paddingL;
    
    debugPrint('RegisterScreen: textScaleFactor=$textScaleFactor, verticalSpacing=$verticalSpacing');
    
    return AuthBackground(
      backgroundColor: AppColors.primaryLight,
      child: SafeArea(
        child: AuthCard(
          minHeight: 400, // Altura mínima original
          maxHeight: 600, // Altura máxima original
          child: SingleChildScrollView(
            // Usamos SingleChildScrollView en lugar de ListView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título
                const AuthTitle(title: "CREAR UNA CUENTA"),
                SizedBox(height: verticalSpacing),

                // Campo de correo
                AuthTextField(
                  controller: emailController,
                  labelText: "Ingresa tu correo",
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: verticalSpacing),

                // Campo de nombre de usuario
                AuthTextField(
                  controller: usernameController,
                  labelText: "Ingresa tu nombre",
                ),
                SizedBox(height: verticalSpacing),

                // Campo de contraseña
                PasswordField(
                  controller: passwordController,
                  labelText: "Ingresa una contraseña",
                  helperText: textScaleFactor > 1.3 
                      ? null 
                      : "Mínimo 8 caracteres, con mayúsculas y números",
                ),
                SizedBox(height: verticalSpacing),

                // Campo de confirmar contraseña
                PasswordField(
                  controller: confirmPasswordController,
                  labelText: "Confirma tu contraseña",
                ),
                SizedBox(height: verticalSpacing),

                // Términos y condiciones
                Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (bool? value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    GestureDetector(
                      onTap: _showTermsAndConditions,
                      child: Text(
                        'Acepto los términos y condiciones',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          decoration: TextDecoration.underline,
                          fontSize: textScaleFactor > 1.3 
                              ? AppDimens.fontS 
                              : AppDimens.fontM,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: verticalSpacing),

                // Botón de crear cuenta
                AuthButton(
                  text: "Crear cuenta",
                  isLoading: _isLoading,
                  onPressed: _termsAccepted ? register : null,
                ),
                SizedBox(height: verticalSpacing),

                // Botón de ya tengo una cuenta
                AuthButton(
                  text: "Ya tengo una cuenta",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  type: AuthButtonType.secondary,
                ),
                
                // Espacio adicional para scroll cuando hay texto grande
                SizedBox(height: textScaleFactor > 1.3 ? 50.0 : 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}