import 'package:flutter/material.dart';

class AppColors {
  // Colores primarios de la aplicación
  static const Color primary = Color(0xFF95B8D1);
  static const Color primaryLight = Color(0xFFB0D1E9);
  static const Color accent = Colors.blue;
  static const Color accentLight = Color(0xFF8BB8D4);

  // Colores de fondos
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBackground = Colors.white;

  // Colores de textos
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Color(0xFF757575);

  // Colores de categorías (mantenemos los nombres originales para compatibilidad)
  static const Color categoryGreen = Color(0xFF95B8D1); // Cambiado a azul
  static const Color categoryBlue = Color(0xFF95B8D1); // Azul
  static const Color categoryRed = Color(0xFF95B8D1); // Cambiado a azul
  static const Color categoryDefault = Color(0xFF95B8D1); // Cambiado a azul
  
  // Nuevo color unificado para categorías 
  static const Color categoryColor = Color(0xFF95B8D1);
  static const Color categoryColorLight = Color(0xFFB0D1E9);
  static const Color categoryColorDark = Color(0xFF6A8EA6);

  // Colores de estados
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;

  // Colores de bordes y sombras
  static const Color border = Color(0xFFDDDDDD);
  static const Color shadow = Color(0x33000000);
}