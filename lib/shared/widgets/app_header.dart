// lib/shared/widgets/app_header.dart
import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPress;
  final List<Widget>? actions;
  final double? height; // Parámetro opcional para altura personalizada

  const AppHeader({
    Key? key,
    required this.title,
    this.onBackPress,
    this.actions,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Altura estándar para todos los headers
    final double standardHeight = height ?? 
     (kToolbarHeight + MediaQuery.of(context).padding.top + 10); // Añadimos 20 unidades más de altura
    
    // Depuración para verificar la altura
    debugPrint('AppHeader altura: $standardHeight');
    
    return Container(
      width: double.infinity,
      height: standardHeight,
      padding: EdgeInsets.only(
        left: AppDimens.paddingL,
        right: AppDimens.paddingL,
        top: MediaQuery.of(context).padding.top, // Padding superior para status bar
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryLight, // Color claro
            AppColors.primary,      // Color principal
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center, // Centrar verticalmente
        children: [
          // Botón de retroceso (opcional) - sin contenedor rectangular
          if (onBackPress != null)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              onPressed: onBackPress,
            ),
          
          // Espacio flexible antes del título
          SizedBox(width: onBackPress != null ? AppDimens.paddingM : 0),
          
          // Título
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: AppDimens.fontXL,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: onBackPress != null ? TextAlign.start : TextAlign.center,
            ),
          ),
          
          // Acciones adicionales (opcionales)
          if (actions != null) ...?actions,
        ],
      ),
    );
  }
}