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
    final Size screenSize = MediaQuery.of(context).size;

    // Calcular tamaños responsivos para los círculos
    final double largeCircleSize = screenSize.width * 0.5;
    final double mediumCircleSize = screenSize.width * 0.375;
    final double smallCircleSize = screenSize.width * 0.25;

    return Stack(
      children: [
        // Background design with curved shapes
        Positioned(
          left: -largeCircleSize / 2,
          top: screenSize.height * 0.2,
          child: Container(
            width: largeCircleSize,
            height: largeCircleSize,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -smallCircleSize / 2,
          top: screenSize.height * 0.1,
          child: Container(
            width: mediumCircleSize,
            height: mediumCircleSize,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -largeCircleSize / 2,
          bottom: screenSize.height * 0.3,
          child: Container(
            width: largeCircleSize,
            height: largeCircleSize,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Main content
        child,
      ],
    );
  }
}
