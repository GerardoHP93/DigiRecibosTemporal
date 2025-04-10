// lib/features/scan/services/image_capture_handler.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:digirecibos/features/scan/screens/ocr_result_screen.dart';
import 'package:digirecibos/features/scan/services/capture_result_processor.dart';

/// Esta clase maneja el procesamiento de imágenes capturadas o PDFs seleccionados
/// y navega a la pantalla de resultados OCR
class ImageCaptureHandler {
  static final ImageCaptureHandler _instance = ImageCaptureHandler._internal();
  final CaptureResultProcessor _captureProcessor = CaptureResultProcessor();

  factory ImageCaptureHandler() {
    return _instance;
  }

  ImageCaptureHandler._internal();

  /// Procesa la imagen capturada desde la cámara o galería
  Future<void> processImage(BuildContext context, File imageFile) async {
    try {
      // Mostrar diálogo de carga
      _showLoadingDialog(context);

      // Procesar la imagen
      final receiptData = await _captureProcessor.processImage(imageFile);
      
      // Cerrar diálogo de carga
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar el diálogo de carga
      }

      // Navegar a la pantalla de resultados OCR
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OcrResultScreen(
              receiptData: receiptData,
              filePath: imageFile.path,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error en processImage: $e');
      // Cerrar diálogo de carga si hay error
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar el diálogo de carga

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar la imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Procesa el archivo PDF seleccionado
  Future<void> processPdf(BuildContext context, File pdfFile, List<int> selectedPages) async {
    try {
      debugPrint('Iniciando procesamiento de PDF con páginas: $selectedPages');
      
      // Mostrar diálogo de carga
      _showLoadingDialog(context, isPdf: true);

      // Procesar el PDF
      final receiptData = await _captureProcessor.processPdf(pdfFile, selectedPages);
      
      debugPrint('Procesamiento de PDF completado: ${receiptData.success}');

      // Cerrar diálogo de carga
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar el diálogo de carga
      }

      // Navegar a la pantalla de resultados OCR
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OcrResultScreen(
              receiptData: receiptData,
              filePath: pdfFile.path,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error en processPdf: $e');
      // Cerrar diálogo de carga si hay error
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar el diálogo de carga

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Muestra diálogo de carga durante el procesamiento
  void _showLoadingDialog(BuildContext context, {bool isPdf = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                "Procesando recibo...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                isPdf 
                    ? "Convirtiendo y analizando el PDF..."
                    : "Analizando imagen y detectando datos...",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              const Text(
                "Esto tomará unos segundos",
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}