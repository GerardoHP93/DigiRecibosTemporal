// lib/features/settings/screens/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/shared/widgets/decorative_background.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Políticas de privacidad'),
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
                      'Política de privacidad',
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
                    '1. Introducción',
                    'Bienvenido a DigiRecibos. La privacidad de nuestros usuarios es una prioridad. Esta Política de privacidad describe detalladamente cómo recopilamos, utilizamos, almacenamos, procesamos y protegemos la información que se obtiene mediante el uso de nuestra aplicación móvil.\n\nAl utilizar DigiRecibos, aceptas esta política. Si no estás de acuerdo con sus términos, te recomendamos no utilizar la aplicación.',
                  ),
                  _buildSection(
                    '2. Información que recopilamos',
                    '2.1 Información proporcionada por el usuario\n• Correo electrónico (requerido)\n• Contraseña (almacenada cifradamente)\n• Nombre de usuario (opcional)\n\n2.2 Información obtenida de los recibos escaneados\n• Monto\n• Fecha\n• Texto completo escaneado del documento, que puede incluir:\n   ○ Nombre del titular\n   ○ Dirección\n   ○ RFC, CURP, número de servicio o cuenta\n   ○ Datos fiscales\n   ○ Información de consumo\n   ○ Ubicación de estaciones de servicio\n\n2.3 Información técnica recolectada automáticamente\n• Dirección IP, modelo de dispositivo, versión del sistema operativo\n• Registros de actividad dentro de la aplicación\n• Preferencias y configuraciones del usuario',
                  ),
                  _buildSection(
                    '3. Uso de la información',
                    'La información recopilada se utiliza exclusivamente para:\n• Analizar recibos mediante tecnología OCR (Google ML Kit)\n• Organizar y almacenar recibos digitalmente\n• Calcular y visualizar estadísticas de consumo\n• Sincronizar datos entre dispositivos\n• Mejorar la experiencia del usuario\n• Cumplir con requerimientos legales o normativos',
                  ),
                  _buildSection(
                    '4. Permisos requeridos',
                    '• Cámara: para capturar recibos en tiempo real.\n• Almacenamiento: para seleccionar imágenes o archivos PDF.\n• Internet: para conectarse a los servicios de Firebase.\n• Almacenamiento temporal: para procesar imágenes y archivos durante el escaneo OCR.',
                  ),
                  _buildSection(
                    '5. Almacenamiento y seguridad',
                    '5.1 Ubicación de almacenamiento\n• Firebase Authentication: credenciales de usuario\n• Firebase Firestore: metadatos de recibos\n• Firebase Storage: archivos originales (fotos o PDFs)\n• Almacenamiento local: configuraciones y categorías personalizadas\n\n5.2 Duración del almacenamiento\n• Los datos se conservarán hasta que el usuario solicite la baja de su cuenta.\n• En caso de inactividad por más de 12 meses, se podrá contactar al usuario para confirmar si desea mantener su cuenta activa. En ausencia de respuesta, los datos podrán ser eliminados.\n• Algunos datos podrían conservarse por razones legales o de seguridad.\n\n5.3 Medidas de seguridad\n• Cifrado de datos en tránsito y almacenamiento\n• Acceso restringido a información sensible\n• Eliminación segura de archivos temporales',
                  ),
                  _buildSection(
                    '6. Compartición de datos',
                    'DigiRecibos no vende ni comparte información personal con terceros.\n\nExcepciones:\n• Cuando sea requerido por una autoridad legal conforme a la legislación vigente\n• En casos de prevención de fraude o actividad sospechosa',
                  ),
                  _buildSection(
                    '7. Derechos del usuario',
                    'El usuario tiene derecho a:\n• Acceder a la información recopilada sobre su cuenta\n• Solicitar la baja de su cuenta y eliminación asociada de datos enviando una solicitud por correo electrónico\n• Ser informado sobre los datos almacenados y su uso\n\nNo es posible eliminar selectivamente datos ni desactivar el procesamiento por OCR desde la aplicación.',
                  ),
                  _buildSection(
                    '8. Cambios en la política',
                    'Esta política podrá actualizarse cuando sea necesario para reflejar cambios en la aplicación, requisitos legales o mejoras de seguridad. En caso de modificaciones sustanciales, se notificará a los usuarios por correo electrónico o mediante un aviso dentro de la aplicación con al menos 15 días naturales de anticipación, salvo por razones legales o de seguridad, en cuyo caso los cambios se aplicarán de inmediato.',
                  ),
                  _buildSection(
                    '9. Contacto',
                    'Correo de soporte: al070003@uacam.mx\n\nLas solicitudes se atenderán en un plazo máximo de 30 días hábiles.',
                  ),
                  const SizedBox(height: AppDimens.paddingXL),
                ],
              ),
            ),
          ),
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
