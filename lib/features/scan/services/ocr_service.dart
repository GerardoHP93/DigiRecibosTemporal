// lib/features/scan/services/ocr_service.dart

import 'dart:io';
import 'package:digirecibos/features/scan/models/receipt_data.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class OcrService {
  static final OcrService _instance = OcrService._internal();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // Patrones OPTIMIZADOS para recibos de CFE (simplificados para mejor rendimiento)
  final RegExp _cfePrimaryAmountPattern = RegExp(r'TOTAL\s+A\s+PAGAR[\s:=]*\$?\s*([\d,\.]+)');
  final RegExp _cfeSimpleAmountPattern = RegExp(r'\$\s*([\d,\.]+)');
  final RegExp _cfeDatePattern = RegExp(r'LIMITE\s+DE\s+PAGO[\s:=]*(\d{1,2})\s+(ENE|FEB|MAR|ABR|MAY|JUN|JUL|AGO|SEP|OCT|NOV|DIC)\s+(\d{2,4})', caseSensitive: false);

  // Patrones mejorados para montos en cualquier tipo de recibo
  final List<RegExp> _totalAmountPatterns = [
    // Patrones de "Total" con máxima prioridad
    RegExp(r'TOTAL\s+A\s+PAGAR[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
    RegExp(r'TOTAL[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
    RegExp(r'COSTO\s+TOTAL[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
    RegExp(r'IMPORTE\s+TOTAL[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
    RegExp(r'GRAN\s+TOTAL[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
    // Patrones adicionales para montos específicos
    RegExp(r'MONTO[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
    RegExp(r'IMPORTE[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
  ];
  
  // Patrones adicionales para montos en recibos de agua
  final List<RegExp> _waterAmountPatterns = [
    RegExp(r'TOTAL\s+A\s+PAGAR[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
    RegExp(r'SERVICIO\s+DE\s+AGUA[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
    RegExp(r'PAGAR[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
  ];
  
  // Patrones adicionales para montos en recibos de gasolina
  final List<RegExp> _gasolineAmountPatterns = [
    RegExp(r'TOTAL[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
    RegExp(r'IMPORTE[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
    RegExp(r'PRECIO[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
    RegExp(r'VENTA[\s:=]*\$?\s*([\d,\.]+)', caseSensitive: false),
  ];

  // Patrones mejorados para fechas
  final List<RegExp> _datePatterns = [
    // Patrones con etiqueta "Fecha"
    RegExp(r'FECHA(?:\s+DE\s+EMISI[OÓ]N)?[\s:=]*(\d{1,2})[\s\/\.\-](\d{1,2}|ENE|FEB|MAR|ABR|MAY|JUN|JUL|AGO|SEP|OCT|NOV|DIC)[\s\/\.\-](\d{2,4})', caseSensitive: false),
    RegExp(r'FECHA(?:\s+DE\s+EXPEDICI[OÓ]N)?[\s:=]*(\d{1,2})[\s\/\.\-](\d{1,2}|ENE|FEB|MAR|ABR|MAY|JUN|JUL|AGO|SEP|OCT|NOV|DIC)[\s\/\.\-](\d{2,4})', caseSensitive: false),
    // Patrones con nombre de mes completo
    RegExp(r'(\d{1,2})(?:\s+DE)?\s+(ENERO|FEBRERO|MARZO|ABRIL|MAYO|JUNIO|JULIO|AGOSTO|SEPTIEMBRE|OCTUBRE|NOVIEMBRE|DICIEMBRE)(?:\s+DE)?\s+(\d{2,4})', caseSensitive: false),
    // Patrones con nombre de mes abreviado
    RegExp(r'(\d{1,2})[\s\/\.\-](ENE|FEB|MAR|ABR|MAY|JUN|JUL|AGO|SEP|OCT|NOV|DIC)[\s\/\.\-](\d{2,4})', caseSensitive: false),
    // Patrones numéricos comunes
    RegExp(r'(\d{1,2})[\s\/\.\-](\d{1,2})[\s\/\.\-](\d{2,4})', caseSensitive: false),
    // Patrones compactos sin separadores
    RegExp(r'(\d{2})(\d{2})(\d{2,4})', caseSensitive: false), // DDMMYYYY o DDMMYY
  ];

  // Mapa para convertir nombres de meses a números (ampliado)
  final Map<String, int> _monthNameToNumber = {
    'ENERO': 1, 'ENE': 1, 'JANUARY': 1, 'JAN': 1, 'E': 1, '01': 1,
    'FEBRERO': 2, 'FEB': 2, 'FEBRUARY': 2, 'F': 2, '02': 2,
    'MARZO': 3, 'MAR': 3, 'MARCH': 3, 'M': 3, '03': 3,
    'ABRIL': 4, 'ABR': 4, 'APRIL': 4, 'APR': 4, 'A': 4, '04': 4,
    'MAYO': 5, 'MAY': 5, 'M': 5, '05': 5,
    'JUNIO': 6, 'JUN': 6, 'JUNE': 6, 'J': 6, '06': 6,
    'JULIO': 7, 'JUL': 7, 'JULY': 7, 'J': 7, '07': 7,
    'AGOSTO': 8, 'AGO': 8, 'AUGUST': 8, 'AUG': 8, 'A': 8, '08': 8,
    'SEPTIEMBRE': 9, 'SEP': 9, 'SEPTEMBER': 9, 'SEPT': 9, 'S': 9, '09': 9,
    'OCTUBRE': 10, 'OCT': 10, 'OCTOBER': 10, 'O': 10, '10': 10,
    'NOVIEMBRE': 11, 'NOV': 11, 'NOVEMBER': 11, 'N': 11, '11': 11,
    'DICIEMBRE': 12, 'DIC': 12, 'DECEMBER': 12, 'DEC': 12, 'D': 12, '12': 12,
  };

  // Singleton pattern
  factory OcrService() {
    return _instance;
  }

  OcrService._internal();

  Future<void> dispose() async {
    await _textRecognizer.close();
  }

  /// Procesa una imagen y extrae datos de recibo (monto y fecha)
  Future<ReceiptData> processImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Imprimir texto reconocido para depuración
      debugPrint('Texto OCR reconocido: ${recognizedText.text}');
      
      // OPTIMIZADO: Detectar primero si es un recibo de CFE para usar el método optimizado
      final text = _normalizeText(recognizedText.text);
      if (_isCfeReceipt(text)) {
        debugPrint('Detectado recibo de CFE, usando método especializado');
        return _extractCfeReceiptData(text, recognizedText.text);
      } else if (_isWaterReceipt(text)) {
        debugPrint('Detectado recibo de AGUA, usando método especializado para agua');
        return _extractWaterReceiptData(text, recognizedText.text);
      } else if (_isGasolineReceipt(text)) {
        debugPrint('Detectado recibo de GASOLINA, usando método especializado para gasolina');
        return _extractGasolineReceiptData(text, recognizedText.text);
      } else {
        debugPrint('Usando método genérico de extracción');
        return _extractGenericReceiptData(text, recognizedText.text);
      }
    } catch (e) {
      debugPrint('Error al procesar la imagen para OCR: $e');
      return ReceiptData(
        amount: null,
        date: null,
        rawText: e.toString(),
        success: false,
        errorMessage: 'Error al procesar la imagen para OCR: $e',
      );
    }
  }

  /// Verifica si el texto corresponde a un recibo de CFE
  bool _isCfeReceipt(String text) {
    return text.contains('CFE') || 
           text.contains('COMISION FEDERAL DE ELECTRICIDAD') || 
           text.contains('ELECTRICIDAD') || 
           (text.contains('ENERGIA') && text.contains('ELECTRICA'));
  }

  /// Verifica si el texto corresponde a un recibo de agua
  bool _isWaterReceipt(String text) {
    return text.contains('JAPAC') || 
           (text.contains('AGUA') && text.contains('POTABLE')) || 
           text.contains('COMISION DE AGUA') || 
           text.contains('JUNTA DE AGUA') || 
           text.contains('SERVICIO DE AGUA');
  }

  /// Verifica si el texto corresponde a un recibo de gasolina
  bool _isGasolineReceipt(String text) {
    return text.contains('GASOLINERA') || 
           text.contains('PEMEX') || 
           (text.contains('LITROS') && (text.contains('MAGNA') || text.contains('PREMIUM'))) ||
           text.contains('COMBUSTIBLE') || 
           text.contains('ESTACION DE SERVICIO');
  }

  /// Método optimizado específicamente para recibos CFE
  ReceiptData _extractCfeReceiptData(String normalizedText, String originalText) {
    double? amount;
    DateTime? date;
    
    // 1. EXTRACCIÓN DE FECHA: Buscar directamente el límite de pago en formato "DD MMM YY"
    final dateMatch = _cfeDatePattern.firstMatch(normalizedText);
    if (dateMatch != null && dateMatch.groupCount >= 3) {
      try {
        int day = int.parse(dateMatch.group(1)!);
        String monthText = dateMatch.group(2)!;
        int? month = _getMonthFromName(monthText);
        String yearText = dateMatch.group(3)!;
        int year = int.parse(yearText);
        
        // Ajustar año de dos dígitos
        if (year < 100) {
          year = year < 50 ? 2000 + year : 1900 + year;
        }
        
        if (month != null && day >= 1 && day <= 31) {
          date = DateTime(year, month, day);
          debugPrint('Fecha CFE encontrada: $date');
        }
      } catch (e) {
        debugPrint('Error al extraer fecha CFE: $e');
      }
    }
    
    // Si no se encontró la fecha con el método principal, buscar en las líneas
    if (date == null) {
      date = _extractCfeDateFromLines(normalizedText);
    }
    
    // Si aún no se encontró fecha, probar patrones generales
    if (date == null) {
      date = _findDateUsingPatterns(normalizedText);
    }
    
    // 2. EXTRACCIÓN DE MONTO: Buscar primero el patrón de "TOTAL A PAGAR"
    final amountMatch = _cfePrimaryAmountPattern.firstMatch(normalizedText);
    if (amountMatch != null && amountMatch.groupCount >= 1) {
      try {
        // Limpiar comas y puntos antes de parsear
        String amountStr = amountMatch.group(1)!;
        amountStr = _cleanAmountString(amountStr);
        amount = double.parse(amountStr);
        debugPrint('Monto CFE encontrado (patrón principal): $amount (original: ${amountMatch.group(1)})');
      } catch (e) {
        debugPrint('Error al extraer monto CFE: $e');
      }
    }
    
    // Si no se encontró con el patrón principal, buscar el símbolo de $
    if (amount == null) {
      final simpleMatch = _cfeSimpleAmountPattern.firstMatch(normalizedText);
      if (simpleMatch != null && simpleMatch.groupCount >= 1) {
        try {
          // Limpiar comas y puntos antes de parsear
          String amountStr = simpleMatch.group(1)!;
          amountStr = _cleanAmountString(amountStr);
          amount = double.parse(amountStr);
          debugPrint('Monto CFE encontrado (patrón simple): $amount (original: ${simpleMatch.group(1)})');
        } catch (e) {
          debugPrint('Error al extraer monto CFE simple: $e');
        }
      }
    }
    
    return ReceiptData(
      amount: amount,
      date: date,
      rawText: originalText,
      success: amount != null || date != null,
      errorMessage: amount == null && date == null ? 'No se pudo extraer información' : null,
    );
  }
  
  /// Método optimizado para recibos de agua
  ReceiptData _extractWaterReceiptData(String normalizedText, String originalText) {
    double? amount;
    DateTime? date;
    
    // 1. EXTRACCIÓN DE FECHA usando múltiples patrones
    date = _findDateUsingPatterns(normalizedText);
    
    // 2. EXTRACCIÓN DE MONTO usando patrones específicos para agua
    amount = _findAmountUsingPatterns(normalizedText, _waterAmountPatterns);
    
    // Si no se encontró con patrones específicos, buscar con patrones generales
    if (amount == null) {
      amount = _findAmountUsingPatterns(normalizedText, _totalAmountPatterns);
    }
    
    // Intento final con patrón simple
    if (amount == null) {
      amount = _findSimpleAmount(normalizedText);
    }
    
    return ReceiptData(
      amount: amount,
      date: date,
      rawText: originalText,
      success: amount != null || date != null,
      errorMessage: amount == null && date == null ? 'No se pudo extraer información del recibo de agua' : null,
    );
  }
  
  /// Método optimizado para recibos de gasolina
  ReceiptData _extractGasolineReceiptData(String normalizedText, String originalText) {
    double? amount;
    DateTime? date;
    
    // 1. EXTRACCIÓN DE FECHA usando múltiples patrones
    date = _findDateUsingPatterns(normalizedText);
    
    // 2. EXTRACCIÓN DE MONTO usando patrones específicos para gasolina
    amount = _findAmountUsingPatterns(normalizedText, _gasolineAmountPatterns);
    
    // Si no se encontró con patrones específicos, buscar con patrones generales
    if (amount == null) {
      amount = _findAmountUsingPatterns(normalizedText, _totalAmountPatterns);
    }
    
    // Intento final con patrón simple
    if (amount == null) {
      amount = _findSimpleAmount(normalizedText);
    }
    
    return ReceiptData(
      amount: amount,
      date: date,
      rawText: originalText,
      success: amount != null || date != null,
      errorMessage: amount == null && date == null ? 'No se pudo extraer información del recibo de gasolina' : null,
    );
  }

  /// Método específico para extraer fechas CFE buscando línea por línea
  DateTime? _extractCfeDateFromLines(String text) {
    // Buscar en líneas individuales
    for (var line in text.split('\n')) {
      if (line.toUpperCase().contains('LIMITE') || line.toUpperCase().contains('PAGO')) {
        // Buscar patrones de mes abreviado
        for (String monthAbbr in ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC']) {
          if (line.toUpperCase().contains(monthAbbr)) {
            // Buscar un número de 1-2 dígitos (día)
            final dayMatches = RegExp(r'(\d{1,2})').allMatches(line).toList();
            
            // Buscar un número de 2-4 dígitos (año)
            final yearMatches = RegExp(r'(\d{2,4})\b').allMatches(line).toList();
            
            if (dayMatches.isNotEmpty && yearMatches.isNotEmpty) {
              try {
                int day = int.parse(dayMatches.first.group(1)!);
                int? month = _getMonthFromName(monthAbbr);
                int year = int.parse(yearMatches.last.group(1)!);
                
                // Ajustar año
                if (year < 100) {
                  year = year < 50 ? 2000 + year : 1900 + year;
                }
                
                if (month != null && day >= 1 && day <= 31) {
                  debugPrint('Fecha encontrada en línea: $day/$month/$year');
                  return DateTime(year, month, day);
                }
              } catch (e) {
                debugPrint('Error en _extractCfeDateFromLines: $e');
              }
            }
          }
        }
      }
    }
    return null;
  }

  /// Método para procesar recibos genéricos, menos optimizado pero más flexible
  ReceiptData _extractGenericReceiptData(String normalizedText, String originalText) {
    debugPrint('Método genérico aplicado al texto');
    
    // 1. EXTRACCIÓN DE FECHA usando múltiples patrones
    final date = _findDateUsingPatterns(normalizedText);
    
    // 2. EXTRACCIÓN DE MONTO usando patrones generales
    final amount = _findAmountUsingPatterns(normalizedText, _totalAmountPatterns);
    
    // Si no se encontró monto con los patrones principales, intentar con patrón simple
    final finalAmount = amount ?? _findSimpleAmount(normalizedText);
    
    debugPrint('Resultados genéricos - Monto: $finalAmount, Fecha: $date');
    
    return ReceiptData(
      amount: finalAmount,
      date: date,
      rawText: originalText,
      success: finalAmount != null || date != null,
      errorMessage: finalAmount == null && date == null ? 'No se pudo extraer información' : null,
    );
  }
  
  /// Encuentra montos usando una lista de patrones, en orden de prioridad
  double? _findAmountUsingPatterns(String text, List<RegExp> patterns) {
    // Recorrer cada patrón en orden
    for (var pattern in patterns) {
      final matches = pattern.allMatches(text).toList();
      
      // Si se encontraron coincidencias, intentar procesar
      if (matches.isNotEmpty) {
        for (var match in matches) {
          if (match.groupCount >= 1 && match.group(1) != null) {
            try {
              // Limpiar y parsear
              final amountStr = match.group(1)!;
              final cleanedAmount = _cleanAmountString(amountStr);
              final amount = double.parse(cleanedAmount);
              
              // Verificar que es un monto válido
              if (amount > 0) {
                debugPrint('Monto encontrado con patrón ${pattern.pattern}: $amount (original: $amountStr)');
                return amount;
              }
            } catch (e) {
              debugPrint('Error parseando monto con patrón ${pattern.pattern}: $e');
            }
          }
        }
      }
    }
    
    return null;
  }
  
  /// Busca un monto simple con el símbolo $
  double? _findSimpleAmount(String text) {
    final simplePattern = RegExp(r'\$\s*([\d,\.]+)');
    final matches = simplePattern.allMatches(text).toList();
    
    if (matches.isNotEmpty) {
      for (var match in matches) {
        if (match.groupCount >= 1 && match.group(1) != null) {
          try {
            final amountStr = match.group(1)!;
            final cleanedAmount = _cleanAmountString(amountStr);
            final amount = double.parse(cleanedAmount);
            
            if (amount > 0) {
              debugPrint('Monto simple encontrado: $amount (original: $amountStr)');
              return amount;
            }
          } catch (e) {
            debugPrint('Error en extracción de monto simple: $e');
          }
        }
      }
    }
    
    return null;
  }

  /// Busca fechas en el texto usando múltiples patrones
  DateTime? _findDateUsingPatterns(String text) {
    for (var pattern in _datePatterns) {
      final matches = pattern.allMatches(text).toList();
      
      if (matches.isNotEmpty) {
        for (var match in matches) {
          if (match.groupCount >= 3) {
            try {
              // Extraer componentes
              final group1 = match.group(1)!;
              final group2 = match.group(2)!;
              final group3 = match.group(3)!;
              
              debugPrint('Grupos de fecha encontrados: $group1, $group2, $group3');
              
              // Determinar si el grupo 2 es un nombre de mes o un número
              int? month;
              if (RegExp(r'^\d+$').hasMatch(group2)) {
                // Es un número
                month = int.parse(group2);
              } else {
                // Es nombre de mes
                month = _getMonthFromName(group2);
              }
              
              if (month == null || month < 1 || month > 12) {
                debugPrint('Mes no válido: $group2');
                continue;
              }
              
              final day = int.parse(group1);
              if (day < 1 || day > 31) {
                debugPrint('Día no válido: $day');
                continue;
              }
              
              // Parsear año y aplicar ajuste si es necesario
              int year = int.parse(group3);
              if (year < 100) {
                year = year < 50 ? 2000 + year : 1900 + year;
              }
              
              // Validar fecha completa (día/mes/año)
              if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year >= 1900) {
                try {
                  final date = DateTime(year, month, day);
                  debugPrint('Fecha válida encontrada: $date');
                  return date;
                } catch (e) {
                  debugPrint('Error creando fecha: $e');
                }
              }
            } catch (e) {
              debugPrint('Error procesando coincidencia de fecha: $e');
            }
          }
        }
      }
    }
    
    return null;
  }

  /// Detecta el tipo de recibo basado en palabras clave
  String _detectReceiptType(String text) {
    if (_isCfeReceipt(text)) {
      return 'cfe';
    } else if (_isWaterReceipt(text)) {
      return 'agua';
    } else if (_isGasolineReceipt(text)) {
      return 'gasolina';
    } else {
      return 'general';
    }
  }

  /// Normaliza el texto para facilitar la extracción
  String _normalizeText(String text) {
    // Convertir a mayúsculas y eliminar caracteres especiales problemáticos
    String normalized = text.toUpperCase()
      .replaceAll('Á', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ú', 'U')
      .replaceAll('Ü', 'U')
      .replaceAll('Ñ', 'N');
    
    return normalized;
  }

  /// Obtiene el número de mes a partir de su nombre
  int? _getMonthFromName(String monthName) {
    final normalizedMonth = monthName.toUpperCase().trim();
    return _monthNameToNumber[normalizedMonth];
  }
  
  /// Limpia un string de monto, removiendo comas y dejando un solo punto decimal
  String _cleanAmountString(String amount) {
    // Primero detectamos si hay punto decimal
    bool hasDecimalPoint = amount.contains('.');
    
    // Quitamos todas las comas que son separadores de miles
    String cleaned = amount.replaceAll(',', '');
    
    // Si encontramos múltiples puntos, dejamos solo el último como punto decimal
    if (hasDecimalPoint) {
      int lastDotIndex = cleaned.lastIndexOf('.');
      if (lastDotIndex != cleaned.indexOf('.')) {
        cleaned = cleaned.replaceAll('.', ',');
        cleaned = cleaned.replaceFirst(',', '.', lastDotIndex);
        cleaned = cleaned.replaceAll(',', '');
      }
    }
    
    return cleaned;
  }
}