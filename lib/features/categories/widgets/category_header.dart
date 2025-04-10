import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';

class CategoryHeader extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;
  final VoidCallback onBackPress;
  final VoidCallback onFilterPress;

  const CategoryHeader({
    Key? key,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
    required this.onBackPress,
    required this.onFilterPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Adaptación a diferentes tamaños de pantalla
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final double iconPadding = isSmallScreen ? AppDimens.paddingS : AppDimens.paddingM;
    final double textPadding = isSmallScreen ? AppDimens.paddingS : AppDimens.paddingL;

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? AppDimens.paddingM : AppDimens.paddingL),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: categoryColor, width: AppDimens.borderWidth),
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              padding: EdgeInsets.all(iconPadding),
              constraints: const BoxConstraints(),
              onPressed: onBackPress,
            ),
          ),
          SizedBox(width: isSmallScreen ? AppDimens.paddingM : AppDimens.paddingL),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: textPadding,
              vertical: AppDimens.paddingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppDimens.radiusXXL),
              border: Border.all(color: categoryColor, width: AppDimens.borderWidth),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: AppDimens.elevationS,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(categoryIcon, color: categoryColor),
                const SizedBox(width: AppDimens.paddingS),
                Text(
                  categoryName,
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: onFilterPress,
          ),
        ],
      ),
    );
  }
}