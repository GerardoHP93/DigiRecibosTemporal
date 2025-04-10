import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';

enum AuthButtonType { primary, secondary }

class AuthButton extends StatelessWidget {
  final String text;
  final Function()? onPressed; // Cambiado de VoidCallback para aceptar funciones asíncronas
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
    
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeight,
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
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: isPrimary 
                    ? AppTextStyles.buttonText
                    : AppTextStyles.buttonText.copyWith(color: AppColors.primary),
              ),
      ),
    );
  }
}