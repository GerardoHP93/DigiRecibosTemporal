import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';

class CountdownTimer extends StatelessWidget {
  final int remainingTime;

  const CountdownTimer({
    Key? key,
    required this.remainingTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimens.paddingL),
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.paddingS, 
        horizontal: AppDimens.paddingL
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, color: Colors.grey[700]),
          const SizedBox(width: AppDimens.paddingS),
          Flexible(
            child: Text(
              "Puedes reenviar en: $remainingTime segundos",
              style: TextStyle(
                fontSize: AppDimens.fontL,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}