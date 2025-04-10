import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';

class AddCategoryButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddCategoryButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tamaño del botón adaptable según el ancho de pantalla
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonSize = screenWidth < 360 ? 40 : 50;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: AppDimens.borderWidth),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: AppDimens.elevationM,
              offset: const Offset(0, 2),
            ),
          ],
          color: AppColors.cardBackground,
        ),
        child: Icon(
          Icons.add, 
          color: Colors.black, 
          size: buttonSize * 0.64, // Tamaño proporcional del ícono
        ),
      ),
    );
  }
}