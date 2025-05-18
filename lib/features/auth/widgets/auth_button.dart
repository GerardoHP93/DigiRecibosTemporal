// lib/features/auth/widgets/auth_button.dart

import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';

enum AuthButtonType { primary, secondary }

class AuthButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final bool isLoading;
  final AuthButtonType type;

  const AuthButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = AuthButtonType.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = type == AuthButtonType.primary;
    // Obtener el factor de escala de texto para adaptación
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final isLargeText = textScaleFactor > 1.3;
    
    // Ajustar la altura del botón según el tamaño del texto
    final double buttonHeight = isLargeText ? 
        AppDimens.buttonHeight * 1.3 : AppDimens.buttonHeight;
    
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : AppColors.background,
          foregroundColor: isPrimary ? Colors.white : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusCircular),
            side: isPrimary ? BorderSide.none : BorderSide(color: AppColors.primary),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(
            vertical: isLargeText ? 16.0 : 12.0,
            horizontal: 16.0,
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                // Estas propiedades son claves para manejar textos largos
                textAlign: TextAlign.center,
                softWrap: true, // Permite saltos de línea automáticos
                overflow: TextOverflow.visible, // Permite que el texto sea visible completamente
                style: isPrimary 
                    ? AppTextStyles.buttonText
                    : AppTextStyles.buttonText.copyWith(color: AppColors.primary),
              ),
      ),
    );
  }
}