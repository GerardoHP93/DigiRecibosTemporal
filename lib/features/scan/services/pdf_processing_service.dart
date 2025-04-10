// lib/features/scan/services/pdf_processing_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:image/image.dart' as img;
import 'ocr_service.dart';
import '../models/receipt_data.dart';

class PdfProcessingService {
  static final PdfProcessingService _instance = PdfProcessingService._internal();
  final OcrService _ocrService = OcrService();
  
  // Singleton pattern
  factory PdfProcessingService() {
    return _instance;
  }

  PdfProcessingService._internal();

  /// Procesa una única página seleccionada de un PDF para extraer datos
  Future<ReceiptData> processPdfPage(File pdfFile, int pageIndex) async {
    PdfDocument? document;
    try {
      // Abrir el documento PDF
      document = await PdfDocument.openFile(pdfFile.path);
      
      // Validar el índice de página
      if (pageIndex < 0 || pageIndex >= document.pageCount) {
        throw Exception('Índice de página inválido');
      }
      
      // Obtener la página
      final page = await document.getPage(pageIndex + 1); // +1 porque las páginas en PDF comienzan en 1
      
      // Renderizar la página como imagen con alta resolución para mejor OCR
      final renderWidth = (page.width * 2).toInt(); // Escala 2x para mejor calidad
      final renderHeight = (page.height * 2).toInt();
      
      final pageImage = await page.render(
        width: renderWidth,
        height: renderHeight,
        backgroundFill: true,
      );
      
      // Convertir los pixels RGBA a un archivo de imagen JPG usando el paquete image
      final tempFile = await _convertPdfPageToImageFile(pageImage);
      
      // Procesar la imagen con OCR
      final receiptData = await _ocrService.processImage(tempFile);
      
      // Liberar recursos
      await tempFile.delete();
      
      return receiptData;
    } catch (e) {
      debugPrint('Error al procesar el PDF: $e');
      return ReceiptData(
        rawText: e.toString(),
        success: false,
        errorMessage: 'Error al procesar el PDF: $e',
      );
    } finally {
      // Liberar recursos del documento
      document?.dispose();
    }
  }

  /// Convierte los píxeles de la página PDF a un archivo de imagen JPG
  Future<File> _convertPdfPageToImageFile(PdfPageImage pageImage) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/pdf_page_$timestamp.jpg';
      
      // Crear una imagen utilizando el paquete 'image'
      final width = pageImage.width;
      final height = pageImage.height;
      
      // Crear una imagen desde los pixels RGBA
      var rawImage = img.Image(width: width, height: height);
      
      // Copiar los píxeles RGBA a la imagen
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixelIndex = (y * width + x) * 4;
          final r = pageImage.pixels[pixelIndex];
          final g = pageImage.pixels[pixelIndex + 1];
          final b = pageImage.pixels[pixelIndex + 2];
          final a = pageImage.pixels[pixelIndex + 3];
          
          rawImage.setPixel(x, y, img.ColorRgba8(r, g, b, a));
        }
      }
      
      // Codificar la imagen como JPG
      final jpgData = img.encodeJpg(rawImage, quality: 90);
      
      // Guardar el archivo
      final file = File(filePath);
      await file.writeAsBytes(jpgData);
      
      return file;
    } catch (e) {
      debugPrint('Error al convertir página PDF a imagen: $e');
      throw Exception('Error al convertir página PDF a imagen: $e');
    }
  }

  /// Procesa múltiples páginas seleccionadas de un PDF y retorna el mejor resultado
  Future<ReceiptData> processPdf(File pdfFile, List<int> selectedPages) async {
    if (selectedPages.isEmpty) {
      return ReceiptData(
        rawText: '',
        success: false,
        errorMessage: 'No se seleccionaron páginas para procesar',
      );
    }

    final results = <ReceiptData>[];
    
    for (final pageIndex in selectedPages) {
      try {
        final result = await processPdfPage(pdfFile, pageIndex);
        results.add(result);
      } catch (e) {
        debugPrint('Error al procesar página $pageIndex: $e');
        // Continuar con la siguiente página si hay error
      }
    }
    
    // Si no se procesó ninguna página correctamente
    if (results.isEmpty) {
      return ReceiptData(
        rawText: '',
        success: false,
        errorMessage: 'No se pudo procesar ninguna página del PDF',
      );
    }
    
    // Encontrar el mejor resultado (el que tiene más información)
    return _findBestResult(results);
  }

  /// Encuentra el mejor resultado de OCR entre varios resultados
  ReceiptData _findBestResult(List<ReceiptData> results) {
    // Ordenar por éxito y completitud de datos
    results.sort((a, b) {
      // Primero por éxito
      if (a.success != b.success) {
        return a.success ? 1 : -1;
      }
      
      // Luego por tener ambos datos
      final aHasBoth = a.amount != null && a.date != null;
      final bHasBoth = b.amount != null && b.date != null;
      
      if (aHasBoth != bHasBoth) {
        return aHasBoth ? 1 : -1;
      }
      
      // Luego por tener al menos uno de los datos
      final aHasAny = a.amount != null || a.date != null;
      final bHasAny = b.amount != null || b.date != null;
      
      if (aHasAny != bHasAny) {
        return aHasAny ? 1 : -1;
      }
      
      // Por último, preferir el que tenga texto más largo (posiblemente más información)
      return a.rawText.length.compareTo(b.rawText.length);
    });
    
    // Retornar el mejor resultado
    return results.last;
  }
}