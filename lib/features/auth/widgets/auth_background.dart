import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Círculo de fondo en la parte superior
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.19,
            left: -MediaQuery.of(context).size.width * 0.28,
            right: -MediaQuery.of(context).size.width * 0.2,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.48,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Contenido principal
          child,
        ],
      ),
    );
  }
}