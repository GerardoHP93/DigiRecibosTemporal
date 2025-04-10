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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingXXXL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.11),
                    
                    // Tarjeta blanca con sombra para el formulario
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: 400,
                        minHeight: minHeight,
                        maxHeight: maxHeight,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: AppDimens.paddingXL),
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
                        padding: const EdgeInsets.all(AppDimens.paddingXL),
                        child: child,
                      ),
                    ),
                    
                    // Espacio flexible para que el formulario quede centrado
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}