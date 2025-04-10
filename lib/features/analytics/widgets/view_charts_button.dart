import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_strings.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';

class ViewChartsButton extends StatelessWidget {
  final VoidCallback onTap;

  const ViewChartsButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Adaptación a diferentes tamaños de pantalla
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final double iconSize = isSmallScreen ? 24 : 32;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.paddingL,
        vertical: AppDimens.paddingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppStrings.viewCharts,
                  style: AppTextStyles.chartLabel,
                ),
                const SizedBox(height: AppDimens.paddingXS),
                Container(
                  padding: EdgeInsets.all(AppDimens.paddingS),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusL),
                  ),
                  child: Icon(Icons.bar_chart, size: iconSize),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}