// lib/features/auth/widgets/auth_card.dart - Con altura ajustada

import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  const AuthCard({
    Key? key,
    required this.child,
    this.minHeight = 450,
    this.maxHeight = 600,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla y el factor de escala de texto
    final screenSize = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    // Ajustar alturas según el factor de escala del texto pero manteniendo un tamaño compacto
    final adjustedMinHeight = textScaleFactor > 1.2 
        ? minHeight
        : minHeight;
    
    // Limitar la altura máxima a un valor más compacto
    // Usar la altura original excepto cuando el texto es muy grande
    final adjustedMaxHeight = textScaleFactor > 1.3
        ? maxHeight * 1.1  // Solo aumentar ligeramente para texto muy grande
        : maxHeight;
    
    debugPrint('AuthCard: textScaleFactor=$textScaleFactor, adjustedMaxHeight=$adjustedMaxHeight');
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Container(
        // Usar un SizedBox con altura fija para limitar el tamaño visual del card
        height: adjustedMaxHeight,
        constraints: BoxConstraints(
          minHeight: adjustedMinHeight,
          maxHeight: adjustedMaxHeight,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: AppDimens.paddingL,
          horizontal: AppDimens.paddingL,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimens.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingL),
          child: child,
        ),
      ),
    );
  }
}