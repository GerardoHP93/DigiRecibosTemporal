// lib/features/settings/screens/help_screen.dart

import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/shared/widgets/decorative_background.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: DecorativeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingL),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Soporte y ayuda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingXL),
                  const Text(
                    'Para brindar asistencia a nuestros usuarios, DigiRecibos cuenta con los siguientes medios de contacto:',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppDimens.paddingL),
                  _buildHelpSection(
                    '1. Sección de ayuda',
                    'La aplicación incluye una sección de ayuda accesible desde: Configuración > Ayuda, donde el usuario encontrará información básica sobre funcionamiento general y permisos requeridos.',
                    Icons.help_outline,
                  ),
                  _buildHelpSection(
                    '2. Contacto de soporte',
                    'Si necesitas soporte adicional o tienes problemas técnicos, puedes comunicarte con nuestro equipo mediante los siguientes medios:\n\n• Correo: al070003@uacam.mx\n• Horario de atención: Lunes a viernes de 9:00 a.m. a 6:00 p.m. (hora del centro de México)',
                    Icons.email_outlined,
                  ),
                  _buildHelpSection(
                    '3. Reporte de errores',
                    'Para reportar fallos técnicos, errores en el escaneo o problemas de sincronización, puedes escribirnos directamente indicando el tipo de problema y el modelo de tu dispositivo.',
                    Icons.bug_report_outlined,
                  ),
                  _buildHelpSection(
                    '4. Sugerencias',
                    'Las sugerencias o comentarios de mejora pueden enviarse al correo de soporte. Todo aporte será considerado para futuras versiones de DigiRecibos.',
                    Icons.lightbulb_outline,
                  ),
                  const SizedBox(height: AppDimens.paddingXL),
                  _buildFaqSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: AppDimens.iconL,
                ),
                const SizedBox(width: AppDimens.paddingM),
                Text(
                  title,
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingM),
            Text(
              content,
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preguntas frecuentes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimens.paddingL),
        _buildFaqItem(
          '¿Cómo puedo crear una categoría personalizada?',
          'En la pantalla principal, toca el botón "+" que aparece debajo de las categorías existentes. Ingresa un nombre para la categoría y selecciona un emoji que la represente.',
        ),
        _buildFaqItem(
          '¿Por qué la app necesita acceso a mi cámara?',
          'DigiRecibos requiere acceso a la cámara para permitirte tomar fotos de tus recibos y procesarlos mediante reconocimiento óptico de caracteres (OCR).',
        ),
        _buildFaqItem(
          '¿Cómo puedo eliminar un recibo?',
          'Abre la categoría donde está el recibo, selecciona el recibo que deseas eliminar, y en la pantalla de detalle presiona el ícono de papelera en la esquina superior derecha.',
        ),
        _buildFaqItem(
          '¿Qué hago si el OCR no detecta correctamente la información?',
          'Si el reconocimiento automático falla, puedes editar manualmente el monto y la fecha en la pantalla de resultados de OCR antes de guardar el recibo.',
        ),
        _buildFaqItem(
          '¿Cómo puedo cambiar mi contraseña?',
          'Cierra sesión y en la pantalla de inicio de sesión presiona el botón "¿Has olvidado tu contraseña?". Recibirás un correo electrónico con un enlace para restablecer tu contraseña.',
        ),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingL,
            0,
            AppDimens.paddingL,
            AppDimens.paddingL,
          ),
          child: Text(
            answer,
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }
}
