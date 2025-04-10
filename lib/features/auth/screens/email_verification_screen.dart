import 'dart:async';
import 'package:flutter/material.dart';
import 'package:digirecibos/services/auth_service.dart';
import 'package:digirecibos/features/home/screens/home_screen.dart';
import 'package:digirecibos/features/auth/widgets/auth_background.dart';
import 'package:digirecibos/features/auth/widgets/auth_card.dart';
import 'package:digirecibos/features/auth/widgets/auth_button.dart';
import 'package:digirecibos/features/auth/widgets/auth_title.dart';
import 'package:digirecibos/features/auth/widgets/countdown_timer.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  // Variable estática para mantener el tiempo del último envío
  static int? lastResendTimeMillis;
  static const int RESEND_TIMEOUT_SECONDS = 60;

  const EmailVerificationScreen({Key? key, required this.email})
      : super(key: key);

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  bool isEmailVerified = false;
  bool canResendEmail = true; // Inicialmente activado
  Timer? timer;
  Timer? countdownTimer;
  int resendTimeout = EmailVerificationScreen
      .RESEND_TIMEOUT_SECONDS; // Tiempo en segundos para reenviar correo
  int remainingTime = 0; // Iniciar el contador en 0

  @override
  void initState() {
    super.initState();
    // Verificar estado inicial
    isEmailVerified = _authService.isEmailVerified();

    // Verificar si hay una restricción de tiempo activa
    _checkResendRestriction();
    if (!isEmailVerified) {
      // Iniciar timer para verificar continuamente si el correo fue verificado
      timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  void _checkResendRestriction() {
    // Si existe una marca de tiempo previa
    if (EmailVerificationScreen.lastResendTimeMillis != null) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final elapsedTime =
          (currentTime - EmailVerificationScreen.lastResendTimeMillis!) ~/ 1000;

      // Si no ha pasado suficiente tiempo desde el último reenvío
      if (elapsedTime < resendTimeout) {
        setState(() {
          canResendEmail = false;
          remainingTime = resendTimeout - elapsedTime;
        });

        // Iniciar el contador regresivo
        startCountdown(initialTime: remainingTime);
      }
    }
  }

  void _updateLastResendTime() {
    EmailVerificationScreen.lastResendTimeMillis =
        DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void dispose() {
    timer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    // Recargar usuario actual
    await _authService.updateEmailVerificationStatus();
    final verified = _authService.isEmailVerified();
    if (verified) {
      timer?.cancel();
      setState(() {
        isEmailVerified = true;
      });
      // Navegar a la pantalla principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  void startCountdown({int? initialTime}) {
    setState(() {
      canResendEmail = false; // Desactivar el botón
      remainingTime =
          initialTime ?? resendTimeout; // Usar tiempo inicial o reiniciar
    });
    // Iniciar el contador
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          canResendEmail = true; // Activar el botón
        }
      });
    });
  }

  Future<void> resendVerificationEmail() async {
    try {
      // Actualizar el tiempo de envío antes de hacer la solicitud
      _updateLastResendTime();

      final result = await _authService.resendVerificationEmail();
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Correo de verificación reenviado'),
            backgroundColor: Colors.green,
          ),
        );
        // Reiniciar el contador
        startCountdown();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reenviar correo de verificación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Detectar si es un error específico de límite de solicitudes
      if (e.toString().contains('too-many-requests') ||
          e.toString().contains('network-request-failed')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Debes esperar un minuto antes de volver a enviar un correo'),
            backgroundColor: Colors.orange,
          ),
        );

        // Mantener el contador activo
        if (canResendEmail) {
          startCountdown();
        }
      } else {
        // Para otros errores, podemos permitir reintentarlo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SafeArea(
        child: AuthCard(
          minHeight: 500,
          maxHeight: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de email
              Icon(
                Icons.mark_email_read,
                size: 60,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimens.paddingL),

              // Título "VERIFICAR CORREO"
              const AuthTitle(title: "VERIFICAR CORREO"),
              const SizedBox(height: AppDimens.paddingL),

              // Instrucciones
              Text(
                'Enviaremos un correo de verificación a:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppDimens.fontL,
                ),
              ),
              const SizedBox(height: AppDimens.paddingS),

              // Email del usuario
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: AppDimens.fontXL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimens.paddingL),

              // Instrucciones adicionales
              Text(
                'Por favor, presiona el botón para verificar tu correo y revisa tu bandeja de entrada.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppDimens.fontL),
              ),
              const SizedBox(height: AppDimens.paddingM),

              // Mensaje sobre spam
              Text(
                'Recuerda revisar tu carpeta de spam',
                style: TextStyle(
                  fontSize: AppDimens.fontM,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: AppDimens.paddingL),

              // Contador visible cuando no se puede reenviar
              if (!canResendEmail) CountdownTimer(remainingTime: remainingTime),

              // Botón de enviar correo de verificación
              AuthButton(
                text: "ENVIAR CORREO DE VERIFICACIÓN",
                isLoading: !canResendEmail,
                onPressed: canResendEmail ? resendVerificationEmail : null,
              ),
              const SizedBox(height: AppDimens.paddingL),

              // Botón para volver al inicio
              AuthButton(
                text: "VOLVER AL INICIO",
                onPressed: () {
                  _authService.signOut();
                  Navigator.of(context).pop();
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
