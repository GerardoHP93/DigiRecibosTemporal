// lib/features/categories/widgets/category_button.dart
import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';

class CategoryButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color; // Mantenemos este parámetro por compatibilidad pero lo ignoramos
  final String id;
  final bool isDefault;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final IconData categoryIcon;

  const CategoryButton({
    Key? key,
    required this.emoji,
    required this.label,
    required this.color,
    required this.id,
    required this.isDefault,
    required this.onTap,
    required this.categoryIcon,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Para adaptar la altura del botón según el tamaño de la pantalla
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonHeight = screenWidth < 360 
        ? AppDimens.categoryButtonHeight * 0.8 
        : AppDimens.categoryButtonHeight;

    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusCircular),
        border: Border.all(color: AppColors.primary, width: AppDimens.borderWidth), // Usar color uniforme
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppDimens.elevationS,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusCircular),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
            child: Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: AppDimens.fontXXL),
                ),
                const SizedBox(width: AppDimens.paddingM),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.categoryName,
                  ),
                ),
                // Agregar botón de eliminar solo para categorías personalizadas
                if (!isDefault && onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    iconSize: AppDimens.iconS,
                    onPressed: onDelete,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}