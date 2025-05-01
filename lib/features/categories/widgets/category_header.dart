// lib/features/categories/widgets/category_header.dart
import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';

class CategoryHeader extends StatelessWidget {
  final String categoryName;
  final Color categoryColor; // Mantenemos pero no lo usaremos directamente
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

  // Método para determinar el color apropiado basado en el ícono
  Color _getColorForIcon(IconData icon) {
    // Asignar colores específicos según el tipo de ícono
    if (icon == Icons.bolt) {
      return Colors.amber; // Color para ⚡
    } else if (icon == Icons.water_drop) {
      return Colors.blue; // Color para 💧
    } else if (icon == Icons.local_gas_station) {
      return Colors.red; // Color para ⛽
    } else if (icon == Icons.shopping_cart) {
      return Colors.green; // Color para 🛒
    } else if (icon == Icons.store) {
      return Colors.purple; // Color para 🏪
    } else if (icon == Icons.smartphone) {
      return Colors.blueGrey; // Color para 📱
    } else if (icon == Icons.laptop) {
      return Colors.indigo; // Color para 💻
    } else if (icon == Icons.directions_car) {
      return Colors.orange; // Color para 🚗
    } else if (icon == Icons.home_work) {
      return Colors.brown; // Color para 🏠
    } else if (icon == Icons.description) {
      return Colors.teal; // Color para 📄
    } else if (icon == Icons.work) {
      return Colors.deepPurple; // Color para 💼
    } else if (icon == Icons.battery_charging_full) {
      return Colors.lime; // Color para 🔋
    }
    
    // Color por defecto para otros íconos
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    // Adaptación a diferentes tamaños de pantalla
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final double iconPadding = isSmallScreen ? AppDimens.paddingS : AppDimens.paddingM;
    final double textPadding = isSmallScreen ? AppDimens.paddingS : AppDimens.paddingL;
    
    // Calcular el ancho aproximado para el contenedor del título (60% del ancho de pantalla)
    final double titleContainerWidth = screenWidth * 0.6;

    // Altura estándar para todos los headers
    final double standardHeight = kToolbarHeight + MediaQuery.of(context).padding.top + 20; // Añadimos 20 unidades más de altura
    
    // Obtenemos el color adecuado para el ícono
    final Color iconColor = _getColorForIcon(categoryIcon);
    
    // Depuración para verificar la altura y el color
    debugPrint('CategoryHeader altura: $standardHeight');
    debugPrint('CategoryIcon color asignado: $iconColor');

    return Container(
      width: double.infinity,
      height: standardHeight,
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
      child: Padding(
        padding: EdgeInsets.only(
          left: isSmallScreen ? AppDimens.paddingM : AppDimens.paddingL,
          right: isSmallScreen ? AppDimens.paddingM : AppDimens.paddingL,
          top: MediaQuery.of(context).padding.top, // Incluye el padding del sistema
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
                  // Usar el color específico para el icono
                  Icon(
                    categoryIcon,
                    color: iconColor, // Usamos el color determinado por el mapeo
                    size: 24.0, // Tamaño explícito
                  ),
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
      ),
    );
  }
}