import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_strings.dart';

class EmptyCategoryMessage extends StatelessWidget {
  const EmptyCategoryMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Adaptarse al tamaño de la pantalla
    final double screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth < 360 ? 48 : 64;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: iconSize,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppDimens.paddingL),
          Text(
            AppStrings.emptyCategory,
            style: TextStyle(
              fontSize: AppDimens.fontL,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}