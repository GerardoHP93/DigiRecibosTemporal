import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimens.dart';

class AppTextStyles {
  // Estilos de título
  static const TextStyle title = TextStyle(
    fontSize: AppDimens.fontXL,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: AppDimens.fontL,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Estilos de texto normal
  static const TextStyle body = TextStyle(
    fontSize: AppDimens.fontM,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: AppDimens.fontS,
    color: AppColors.textSecondary,
  );

  // Estilos de botones
  static const TextStyle buttonText = TextStyle(
    fontSize: AppDimens.fontL,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Estilos específicos
  static const TextStyle greeting = TextStyle(
    fontSize: AppDimens.fontXL,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle categoryName = TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
    fontSize: AppDimens.fontL,
  );

  static const TextStyle fileItemName = TextStyle(
    fontSize: AppDimens.fontS,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontSize: AppDimens.fontXL,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle chartLabel = TextStyle(
    fontSize: AppDimens.fontS,
  );

// Añadir estos estilos si no existen ya
  static const TextStyle authMessage = TextStyle(
    fontSize: AppDimens.fontM,
    color: Colors.grey,
  );

  static const TextStyle successTitle = TextStyle(
    fontSize: AppDimens.fontXXL,
    fontWeight: FontWeight.bold,
    color: AppColors.success,
  );
}

// import 'package:flutter/material.dart';
// import 'app_colors.dart';

// class AppTextStyles {
//   // Títulos
//   static const TextStyle title = TextStyle(
//     fontSize: 18,
//     fontWeight: FontWeight.bold,
//     color: AppColors.textPrimary,
//   );
  
//   static const TextStyle subtitle = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.bold,
//     color: AppColors.textPrimary,
//   );
  
//   // Texto normal
//   static const TextStyle body = TextStyle(
//     fontSize: 14,
//     color: AppColors.textPrimary,
//   );
  
//   static const TextStyle bodySmall = TextStyle(
//     fontSize: 12,
//     color: AppColors.textSecondary,
//   );
  
//   // Categorías
//   static const TextStyle categoryLabel = TextStyle(
//     color: AppColors.textPrimary,
//     fontWeight: FontWeight.w500,
//     fontSize: 16,
//   );
  
//   // Para emoji
//   static const TextStyle emoji = TextStyle(
//     fontSize: 24,
//   );
  
//   // Para botones
//   static const TextStyle buttonText = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.w500,
//     color: Colors.white,
//   );
  
//   // Para diálogos
//   static const TextStyle dialogTitle = TextStyle(
//     fontSize: 18,
//     fontWeight: FontWeight.bold,
//   );
// }