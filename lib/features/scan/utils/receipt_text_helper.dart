// lib/features/scan/utils/receipt_text_helper.dart

import 'package:flutter/foundation.dart';

/// Clase utilitaria para procesar texto específico de recibos mexicanos
class ReceiptTextHelper {
  /// Detecta el tipo de recibo basado en su contenido
  static String detectReceiptType(String text) {
    text = text.toUpperCase();
    
    // Detectar recibos de CFE
    if (_hasCfeKeywords(text)) {
      return 'cfe';
    }
    
    // Detectar recibos de agua
    if (_hasAguaKeywords(text)) {
      return 'agua';
    }
    
    // Detectar recibos de gasolina
    if (_hasGasolinaKeywords(text)) {
      return 'gasolina';
    }
    
    // Tipo general por defecto
    return 'general';
  }
  
  /// Verifica si el texto contiene palabras clave de recibos de CFE
  static bool _hasCfeKeywords(String text) {
    final keywords = [
      'CFE',
      'COMISION FEDERAL',
      'ELECTRICIDAD',
      'ENERGIA ELECTRICA',
      'KWH',
      'BASICO',
      'INTERMEDIO',
      'EXCEDENTE'
    ];
    
    return _containsAnyKeyword(text, keywords);
  }
  
  /// Verifica si el texto contiene palabras clave de recibos de agua
  static bool _hasAguaKeywords(String text) {
    final keywords = [
      'AGUA',
      'JAPAC',
      'POTABLE',
      'ALCANTARILLADO',
      'CONSUMO DE AGUA',
      'SERVICIOS DE AGUA',
      'AGUA POTABLE',
      'METRO CUBICO',
      'M3'
    ];
    
    return _containsAnyKeyword(text, keywords);
  }
  
  /// Verifica si el texto contiene palabras clave de recibos de gasolina
  static bool _hasGasolinaKeywords(String text) {
    final keywords = [
      'GASOLINA',
      'GASOLINERA',
      'PEMEX',
      'LITROS',
      'MAGNA',
      'PREMIUM',
      'DIESEL',
      'COMBUSTIBLE',
      'DISPENSARIO'
    ];
    
    return _containsAnyKeyword(text, keywords);
  }
  
  /// Verifica si el texto contiene alguna de las palabras clave
  static bool _containsAnyKeyword(String text, List<String> keywords) {
    for (var keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
  
  /// Extrae texto alrededor de una palabra clave específica
  static String extractContextAroundKeyword(String text, String keyword, {int radius = 50}) {
    text = text.toUpperCase();
    keyword = keyword.toUpperCase();
    
    final index = text.indexOf(keyword);
    if (index == -1) {
      return '';
    }
    
    final start = (index - radius).clamp(0, text.length);
    final end = (index + keyword.length + radius).clamp(0, text.length);
    
    return text.substring(start, end);
  }
  
  /// Extrae todas las cifras numéricas que podrían ser montos de un texto
  static List<double> extractPossibleAmounts(String text) {
    // Buscar patrones como $123.45 o simplemente 123.45
    final regex = RegExp(r'(?:\$\s*)?([\d,]{1,3}(?:,\d{3})*(?:\.\d{2})?)(?:\s*(?:MXN|MN|PESOS))?', caseSensitive: false);
    final matches = regex.allMatches(text);
    
    List<double> amounts = [];
    for (var match in matches) {
      if (match.groupCount >= 1) {
        final amountStr = match.group(1)?.replaceAll(',', '');
        if (amountStr != null) {
          try {
            final amount = double.parse(amountStr);
            if (amount > 0) {
              amounts.add(amount);
            }
          } catch (e) {
            // Ignorar errores de parsing
          }
        }
      }
    }
    
    return amounts;
  }
  
  /// Clasifica un conjunto de montos para determinar cuál es más probable que sea el total
  static Map<String, double> classifyAmounts(List<double> amounts, String text) {
    if (amounts.isEmpty) {
      return {};
    }
    
    Map<String, double> result = {};
    
    // Ordenar de mayor a menor
    amounts.sort((a, b) => b.compareTo(a));
    
    // El monto más grande es un candidato para el total
    result['probable_total'] = amounts.first;
    
    // Si tenemos múltiples montos, el segundo más grande podría ser el subtotal
    if (amounts.length > 1) {
      result['probable_subtotal'] = amounts[1];
    }
    
    // Si tenemos al menos 3 montos y hay una relación de IVA (16%)
    if (amounts.length >= 3) {
      for (int i = 0; i < amounts.length - 1; i++) {
        for (int j = i + 1; j < amounts.length; j++) {
          // Verificar si un monto es aproximadamente el 16% de otro
          final larger = amounts[i];
          final smaller = amounts[j];
          
          // Verificar si smaller es aproximadamente 16% de larger
          final ratio = smaller / larger;
          if ((ratio - 0.16).abs() < 0.02) { // Tolerancia de ±2%
            result['probable_total'] = larger;
            result['probable_iva'] = smaller;
            // El subtotal sería el total - iva
            result['probable_subtotal'] = larger - smaller;
            break;
          }
        }
      }
    }
    
    // Buscar contexto de palabras clave para refinar la clasificación
    for (var keyword in ['TOTAL', 'IMPORTE TOTAL', 'TOTAL A PAGAR']) {
      final context = extractContextAroundKeyword(text, keyword);
      
      // Si encontramos un monto en el contexto de "TOTAL"
      final amountsInContext = extractPossibleAmounts(context);
      if (amountsInContext.isNotEmpty) {
        // Actualizar el probable total con este monto
        result['confirmed_total'] = amountsInContext.first;
        break;
      }
    }
    
    return result;
  }
  
  /// Limpia un texto para mejorar la detección de información
  static String cleanText(String text) {
    // Normalizar espacios
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    
    // Normalizar caracteres especiales comunes en recibos
    text = text.replaceAll(r'$','\$');
    
    // Normalizar separadores de miles y decimales
    text = text.replaceAll(RegExp(r'(\d),(\d{3})'), r'$1$2'); // Eliminar comas como separadores de miles
    
    return text;
  }
}