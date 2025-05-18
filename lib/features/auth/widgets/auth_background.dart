// lib/features/auth/widgets/auth_background.dart

import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const AuthBackground({
    Key? key,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla para mejor adaptabilidad
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Círculo de fondo en la parte superior (sin cambios)
          Positioned(
            top: -screenSize.height * 0.19,
            left: -screenSize.width * 0.28,
            right: -screenSize.width * 0.2,
            child: Container(
              height: screenSize.height * 0.48,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Contenido principal - MODIFICADO PARA CENTRAR VERTICALMENTE
          Center(  // Añadir Center aquí para centrar verticalmente
            child: SingleChildScrollView(  // Mantener ScrollView para adaptabilidad
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}