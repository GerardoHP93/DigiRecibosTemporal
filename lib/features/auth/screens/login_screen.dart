import 'package:flutter/material.dart';
import 'package:digirecibos/services/auth_service.dart';
import 'package:digirecibos/features/home/screens/home_screen.dart';
import 'package:digirecibos/features/auth/screens/email_verification_screen.dart';
import 'package:digirecibos/features/auth/screens/forgot_password_screen.dart';
import 'package:digirecibos/features/auth/screens/register_screen.dart';
import 'package:digirecibos/features/auth/widgets/auth_background.dart';
import 'package:digirecibos/features/auth/widgets/auth_card.dart';
import 'package:digirecibos/features/auth/widgets/auth_button.dart';
import 'package:digirecibos/features/auth/widgets/auth_text_field.dart';
import 'package:digirecibos/features/auth/widgets/password_field.dart';
import 'package:digirecibos/features/auth/widgets/auth_title.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool _isLoading = false;

  // Validación de formulario
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La contraseña es obligatoria';
    }
    return null;
  }

  // Validar todos los campos antes de enviar
  bool _validateForm() {
    bool isValid = true;
    
    // Validar ambos campos
    final emailError = _validateEmail(emailController.text);
    final passwordError = _validatePassword(passwordController.text);
    
    if (emailError != null || passwordError != null) {
      // Mostrar el primer error encontrado
      String errorMessage = emailError ?? passwordError ?? 'Por favor completa todos los campos';
      
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

  void login() async {
    // Validar el formulario antes de proceder
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await authService.loginUser(
      emailController.text.trim(),
      passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else if (result['message'] == 'email_not_verified') {
      // El usuario existe pero no ha verificado su correo
      Navigator.push(
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
      child: SafeArea(
        child: AuthCard(
          minHeight: 550,
          maxHeight: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título
              const AuthTitle(title: "INICIAR SESIÓN"),
              const SizedBox(height: AppDimens.paddingXL),
              
              // Campo de correo
              AuthTextField(
                controller: emailController,
                labelText: "Ingresa tu correo",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimens.paddingL),
              
              // Campo de contraseña
              PasswordField(
                controller: passwordController,
                labelText: "Contraseña",
              ),
              const SizedBox(height: AppDimens.paddingS),
              
              // Enlace para recuperar contraseña
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "¿Has olvidado tu contraseña?",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.paddingXL),
              
              // Botón de iniciar sesión
              AuthButton(
                text: "Iniciar Sesión",
                isLoading: _isLoading,
                onPressed: login,
              ),
              const SizedBox(height: AppDimens.paddingL),
              
              // Botón de registro
              AuthButton(
                text: "Registrarse",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
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