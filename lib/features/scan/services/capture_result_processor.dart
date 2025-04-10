// lib/features/scan/services/capture_result_processor.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:digirecibos/features/scan/models/receipt_data.dart';
import 'package:digirecibos/features/scan/services/ocr_service.dart';
import 'package:digirecibos/features/scan/services/image_processing_service.dart';
import 'package:digirecibos/features/scan/services/pdf_processing_service.dart';

/// Procesador de resultados de captura optimizado pero sin uso problemático de compute
class CaptureResultProcessor {
  static final CaptureResultProcessor _instance = CaptureResultProcessor._internal();
  final OcrService _ocrService = OcrService();
  final ImageProcessingService _imageProcessingService = ImageProcessingService();
  final PdfProcessingService _pdfProcessingService = PdfProcessingService();
  
  // Singleton pattern
  factory CaptureResultProcessor() {
    return _instance;
  }
  
  CaptureResultProcessor._internal();
  
  /// Procesa una imagen para extraer datos mejorados
  Future<ReceiptData> processImage(File imageFile) async {
    try {
      // Pre-procesar la imagen para mejorar resultados
      final processedImage = await _imageProcessingService.preprocessImage(imageFile);
      
      // Ejecutar reconocimiento OCR
      final receiptData = await _ocrService.processImage(processedImage);
      
      // Si no se encontraron datos importantes, intentar con la imagen original
      if (!receiptData.success || (receiptData.amount == null && receiptData.date == null)) {
        debugPrint('Intentando con imagen original como respaldo...');
        final originalReceiptData = await _ocrService.processImage(imageFile);
        
        // Si la imagen original dio mejores resultados, usar esos
        if (_isBetterResult(originalReceiptData, receiptData)) {
          return originalReceiptData;
        }
      }
      
      return receiptData;
    } catch (e) {
      debugPrint('Error en el procesamiento de captura: $e');
      // Si hay algún error, intentar con la imagen original como último recurso
      try {
        return await _ocrService.processImage(imageFile);
      } catch (e2) {
        return ReceiptData(
          rawText: 'Error: $e',
          success: false,
          errorMessage: 'Error al procesar la imagen: $e',
        );
      }
    }
  }
  
  // Determinar cuál resultado es mejor
  bool _isBetterResult(ReceiptData r1, ReceiptData r2) {
    // Si el primero tiene ambos datos y el segundo no, el primero es mejor
    if (r1.amount != null && r1.date != null && (r2.amount == null || r2.date == null)) {
      return true;
    }
    
    // Si el segundo no tiene ningún dato y el primero tiene al menos uno, el primero es mejor
    if (!r2.success && r1.success) {
      return true;
    }
    
    return false;
  }
  
  /// Procesa un PDF para extraer datos
  Future<ReceiptData> processPdf(File pdfFile, List<int> selectedPages) async {
    try {
      debugPrint('Procesando PDF con páginas seleccionadas: $selectedPages');
      // Utilizar el servicio dedicado de procesamiento de PDF
      final receiptData = await _pdfProcessingService.processPdf(pdfFile, selectedPages);
      
      // Registrar resultado para depuración
      debugPrint('Resultado del procesamiento de PDF: ${receiptData.success}');
      debugPrint('Monto: ${receiptData.amount}, Fecha: ${receiptData.date}');
      
      return receiptData;
    } catch (e) {
      debugPrint('Error al procesar el PDF: $e');
      return ReceiptData(
        rawText: 'Error al procesar el PDF: $e',
        success: false,
        errorMessage: 'Error al procesar el PDF: $e',
      );
    }
  }
}