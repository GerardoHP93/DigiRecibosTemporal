import 'package:flutter/material.dart';
import 'package:digirecibos/services/auth_service.dart';
import 'package:digirecibos/features/auth/screens/login_screen.dart';
import 'package:digirecibos/features/auth/widgets/auth_background.dart';
import 'package:digirecibos/features/auth/widgets/auth_card.dart';
import 'package:digirecibos/features/auth/widgets/auth_button.dart';
import 'package:digirecibos/features/auth/widgets/auth_text_field.dart';
import 'package:digirecibos/features/auth/widgets/auth_title.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  // Validación de correo electrónico
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

  // Validar el campo antes de enviar
  bool _validateForm() {
    final emailError = _validateEmail(emailController.text);

    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailError),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  void _sendResetPasswordEmail() async {
    if (!_validateForm()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await authService.resetPassword(emailController.text.trim());
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Stack(
        children: [
          // Botón de retroceso
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: AuthCard(
              minHeight: 450,
              maxHeight: 500,
              child: _emailSent ? _buildSuccessContent() : _buildFormContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Título
        const AuthTitle(title: "RECUPERAR CONTRASEÑA"),
        const SizedBox(height: AppDimens.paddingL),

        // Texto explicativo
        Text(
          "Ingresa tu correo electrónico para recibir un enlace de recuperación de contraseña",
          style: TextStyle(
            fontSize: AppDimens.fontM,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.paddingXL),

        // Campo de correo
        AuthTextField(
          controller: emailController,
          labelText: "Ingresa tu correo",
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppDimens.paddingXXL),

        // Botón de enviar enlace
        AuthButton(
          text: "Enviar Enlace",
          isLoading: _isLoading,
          onPressed: _sendResetPasswordEmail,
        ),
        const SizedBox(height: AppDimens.paddingL),

        // Botón para volver a iniciar sesión
        AuthButton(
          text: "Volver a Iniciar Sesión",
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          type: AuthButtonType.secondary,
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icono de confirmación
        const Icon(
          Icons.check_circle,
          size: 60,
          color: Colors.green,
        ),
        const SizedBox(height: AppDimens.paddingL),

        // Título de confirmación
        Text(
          "¡Correo Enviado!",
          style: TextStyle(
            fontSize: AppDimens.fontXXL,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.paddingL),

        // Mensaje de confirmación
        Text(
          "Hemos enviado un enlace de recuperación de contraseña a ${emailController.text}. Por favor, revisa tu bandeja de entrada y sigue las instrucciones.",
          style: TextStyle(
            fontSize: AppDimens.fontM,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.paddingXXL),

        // Botón para volver a iniciar sesión
        AuthButton(
          text: "Volver a Iniciar Sesión",
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          type: AuthButtonType.secondary,
        ),
      ],
    );
  }
}
