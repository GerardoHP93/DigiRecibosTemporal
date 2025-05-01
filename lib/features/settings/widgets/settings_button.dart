// lib/features/settings/widgets/settings_button.dart

import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';

class SettingsButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SettingsButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppDimens.buttonHeight,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusCircular), // Cambiado a radiusCircular para bordes más redondeados
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: AppDimens.elevationS,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusCircular), // Importante: aplicar el mismo radio al Material
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusCircular), // Importante: aplicar el mismo radio al InkWell
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.subtitle,
            ),
          ),
        ),
      ),
    );
  }
}