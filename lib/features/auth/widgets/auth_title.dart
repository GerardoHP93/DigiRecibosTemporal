import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';

class AuthTitle extends StatelessWidget {
  final String title;

  const AuthTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingM),
      child: Text(
        title,
        style: AppTextStyles.title,
        textAlign: TextAlign.center,
      ),
    );
  }
}