// lib/features/analytics/widgets/view_charts_button.dart
import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_strings.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/features/analytics/screens/charts_screen.dart';

class ViewChartsButton extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const ViewChartsButton({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
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
            onTap: () => _navigateToChartsScreen(context),
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

  // Método para navegar a la pantalla de gráficas
  void _navigateToChartsScreen(BuildContext context) {
    debugPrint('Navegando a ChartsScreen para categoría: $categoryId ($categoryName)');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartsScreen(
          categoryId: categoryId,
          categoryName: categoryName,
          categoryColor: categoryColor,
          categoryIcon: categoryIcon,
        ),
      ),
    );
  }
}