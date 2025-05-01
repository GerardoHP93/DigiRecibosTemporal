import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';

class DecorativeBackground extends StatelessWidget {
  final Widget child;
  final Color circleColor;

  const DecorativeBackground({
    Key? key,
    required this.child,
    this.circleColor = AppColors.primaryLight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fondo limpio sin círculos
    return Container(
      color: AppColors.background,
      child: child,
    );
  }
}