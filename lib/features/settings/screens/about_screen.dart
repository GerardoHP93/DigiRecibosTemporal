// lib/features/settings/screens/about_screen.dart

import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/features/settings/screens/privacy_policy_screen.dart';
import 'package:digirecibos/features/settings/screens/help_screen.dart';
import 'package:digirecibos/features/settings/screens/terms_conditions_screen.dart';
import 'package:digirecibos/shared/widgets/decorative_background.dart';
import 'package:digirecibos/shared/widgets/app_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: Column(
          children: [
            // Usar el nuevo header unificado
            AppHeader(
              title: 'Acerca de',
              onBackPress: () => Navigator.pop(context),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.paddingL),
                child: Column(
                  children: [
                    // Logo y versión
                    const SizedBox(height: AppDimens.paddingXL),
                    _buildLogoSection(),
                    const SizedBox(height: AppDimens.paddingXXL),

                    // Botones de navegación
                    _buildNavigationButton(
                      context: context,
                      icon: Icons.privacy_tip_outlined,
                      label: 'Políticas de privacidad',
                      onTap: () => _navigateToPrivacyPolicy(context),
                    ),
                    const SizedBox(height: AppDimens.paddingL),
                    _buildNavigationButton(
                      context: context,
                      icon: Icons.gavel_outlined,
                      label: 'Términos y condiciones',
                      onTap: () => _navigateToTermsConditions(context),
                    ),
                    const SizedBox(height: AppDimens.paddingL),
                    _buildNavigationButton(
                      context: context,
                      icon: Icons.help_outline,
                      label: 'Ayuda',
                      onTap: () => _navigateToHelp(context),
                    ),

                    const Spacer(),

                    // Información de contacto
                    const Text(
                      'DigiRecibos © 2025',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimens.paddingXS),
                    const Text(
                      'Desarrollado por Gerardo Herrera y Jair Balan',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.paddingL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo o imagen de la app
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.receipt_long,
              size: 70,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.paddingL),
        const Text(
          'DigiRecibos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimens.paddingXS),
        const Text(
          'Versión 0.0.2',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimens.paddingL,
              horizontal: AppDimens.paddingL,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppDimens.paddingL),
                Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: AppDimens.iconXS,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  void _navigateToHelp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpScreen()),
    );
  }

  void _navigateToTermsConditions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsConditionsScreen()),
    );
  }
}