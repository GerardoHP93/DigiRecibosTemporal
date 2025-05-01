// lib/features/settings/screens/terms_conditions_screen.dart

import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/shared/widgets/decorative_background.dart';
import 'package:digirecibos/shared/widgets/app_header.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: Column(
          children: [
            // Usar el nuevo header unificado
            AppHeader(
              title: 'Términos y Condiciones',
              onBackPress: () => Navigator.pop(context),
            ),
            
            Expanded(
              child: SafeArea(
                top: false, // Ya está manejado por el AppHeader
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.paddingL),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Términos y condiciones',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimens.paddingS),
                        const Center(
                          child: Text(
                            'Última actualización: 10 de abril de 2025',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimens.paddingL),
                        _buildSection(
                          '1. Aceptación de los términos',
                          'Al utilizar la aplicación DigiRecibos, el usuario acepta expresamente los presentes Términos y condiciones, así como la Política de privacidad. En caso de no aceptar alguno de los términos, se debe suspender el uso de la aplicación.',
                        ),
                        // Resto de secciones...
                        _buildSection(
                          '2. Uso autorizado',
                          '• El usuario puede utilizar DigiRecibos únicamente con fines personales y no comerciales.\n• Está prohibido usar la aplicación para actividades ilícitas, automatización de procesos no autorizados o análisis de datos con fines de explotación comercial.\n• No está permitido descompilar, modificar, replicar ni redistribuir el contenido, funciones o diseño de DigiRecibos.',
                        ),
                        _buildSection(
                          '3. Propiedad intelectual',
                          'La aplicación, su código fuente, interfaces, nombre, logotipo, diseño y cualquier contenido derivado son propiedad exclusiva de sus creadores y están protegidos por las leyes de propiedad intelectual aplicables.',
                        ),
                        _buildSection(
                          '4. Registro y seguridad de la cuenta',
                          '• El usuario es responsable de mantener la confidencialidad de sus credenciales de acceso.\n• La actividad realizada desde su cuenta será considerada bajo su responsabilidad.\n• DigiRecibos no ofrece, por el momento, mecanismos de verificación en dos pasos.',
                        ),
                        _buildSection(
                          '5. Limitación de responsabilidad',
                          '• DigiRecibos no garantiza que los resultados del OCR sean precisos en todos los casos. El usuario es responsable de verificar la exactitud de la información procesada.\n• No se asume responsabilidad por pérdidas de datos originadas por causas externas, fallas técnicas o mal uso de la aplicación.',
                        ),
                        _buildSection(
                          '6. Modificaciones',
                          'DigiRecibos se reserva el derecho de actualizar la aplicación, modificar funcionalidades, interfaz o estos términos, notificando previamente a los usuarios por medios adecuados.',
                        ),
                        _buildSection(
                          '7. Terminación',
                          'Se podrá suspender o cancelar el acceso del usuario a la aplicación si incurre en uso indebido, violación de estos términos, o si representa un riesgo para otros usuarios o la plataforma.',
                        ),
                        _buildSection(
                          '8. Legislación aplicable',
                          'Estos Términos y condiciones se interpretan y aplican conforme a las leyes vigentes de los Estados Unidos Mexicanos. Cualquier controversia será resuelta por los tribunales competentes conforme a dicha jurisdicción.',
                        ),

                        const SizedBox(height: AppDimens.paddingXL),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: AppDimens.paddingM),
        Text(
          content,
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppDimens.paddingL),
        const Divider(),
        const SizedBox(height: AppDimens.paddingL),
      ],
    );
  }
}