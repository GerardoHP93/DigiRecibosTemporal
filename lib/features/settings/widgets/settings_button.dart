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
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(AppDimens.radiusCircular),
      ),
      child: Material(
        color: AppColors.background,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusCircular),
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