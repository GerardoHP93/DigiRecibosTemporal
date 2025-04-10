// lib/shared/widgets/app_bottom_navigation.dart

import 'package:digirecibos/shared/widgets/scan_modal.dart';
import 'package:flutter/material.dart';
import 'package:digirecibos/features/home/screens/home_screen.dart';
import 'package:digirecibos/features/settings/screens/settings_screen.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  // Eliminamos el const del constructor
  AppBottomNavigation({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Adaptación a diferentes tamaños de pantalla
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final double navHeight = isSmallScreen ? 12 : AppDimens.bottomNavHeight;
    final double iconSize = isSmallScreen ? 20 : AppDimens.iconM;

    return Container(
      padding: EdgeInsets.symmetric(vertical: navHeight),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXXL)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppDimens.elevationM,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.home,
              size: iconSize,
              color: currentIndex == 0 ? AppColors.accent : null,
            ),
            onPressed: () {
              if (currentIndex != 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.receipt_long, size: iconSize),
            onPressed: () {
              // Mostrar modal de escaneo usando la función de utilidad
              showScanModal(context);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              size: iconSize,
              color: currentIndex == 2 ? AppColors.accent : null,
            ),
            onPressed: () {
              if (currentIndex != 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}