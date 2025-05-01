// lib/features/categories/widgets/category_header.dart
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
    
    // Calcular el ancho aproximado para el contenedor del título (60% del ancho de pantalla)
    final double titleContainerWidth = screenWidth * 0.6;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: isSmallScreen ? AppDimens.paddingM : AppDimens.paddingL,
        right: isSmallScreen ? AppDimens.paddingM : AppDimens.paddingL,
        top: MediaQuery.of(context).padding.top + AppDimens.paddingM, // Incluye el padding del sistema
        bottom: AppDimens.paddingM,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryLight, // Color claro (B0D1E9)
            AppColors.primary,      // Color principal (95B8D1)
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Row(
        children: [
          // Botón de regreso
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.primary, width: AppDimens.borderWidth),
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
          
          // Contenedor del título con ancho fijo
          Container(
            width: titleContainerWidth,
            padding: EdgeInsets.symmetric(
              horizontal: textPadding,
              vertical: AppDimens.paddingS,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusXXL),
              border: Border.all(color: AppColors.primary, width: AppDimens.borderWidth),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: AppDimens.elevationS,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Usar el color original del ícono de categoría
                Icon(categoryIcon, color: categoryColor), // Mantener el color original
                const SizedBox(width: AppDimens.paddingS),
                Expanded(
                  child: Text(
                    categoryName,
                    style: AppTextStyles.subtitle,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Icono de filtro
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: onFilterPress,
          ),
        ],
      ),
    );
  }
}