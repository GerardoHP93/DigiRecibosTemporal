// lib/features/scan/services/image_processing_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageProcessingService {
  static final ImageProcessingService _instance = ImageProcessingService._internal();
  
  // Singleton pattern
  factory ImageProcessingService() {
    return _instance;
  }
  
  ImageProcessingService._internal();

  /// Preprocesa una imagen para mejorar los resultados del OCR (versión optimizada)
  Future<File> preprocessImage(File imageFile) async {
    try {
      // Leer la imagen
      final bytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      
      if (decodedImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }
      
      // Aplicar procesamiento optimizado para mejorar velocidad
      var processed = img.grayscale(decodedImage);
      
      // Mejorar contraste para acentuar el texto
      processed = img.contrast(processed, contrast: 20);
      
      // Reducir ruido con un desenfoque leve
      processed = img.gaussianBlur(processed, radius: 1);
      
      // Aplicar umbralización para destacar el texto
      processed = _optimizedBinarize(processed);
      
      // Guardar la imagen procesada
      final processedImagePath = await _saveProcessedImage(img.encodeJpg(processed, quality: 90));
      
      return File(processedImagePath);
    } catch (e) {
      debugPrint('Error al preprocesar la imagen: $e');
      // Si hay un error, devolver la imagen original
      return imageFile;
    }
  }
  
  /// Versión optimizada de binarización (blanco y negro) para mejorar OCR
  img.Image _optimizedBinarize(img.Image image) {
    final result = img.Image.from(image);
    final threshold = 128;
    
    for (var y = 0; y < result.height; y++) {
      for (var x = 0; x < result.width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = (img.getLuminance(pixel) * 255).toInt();
        
        if (luminance > threshold) {
          result.setPixel(x, y, img.ColorRgb8(255, 255, 255)); // Blanco
        } else {
          result.setPixel(x, y, img.ColorRgb8(0, 0, 0)); // Negro
        }
      }
    }
    
    return result;
  }
  
  /// Guarda la imagen procesada en un archivo temporal
  Future<String> _saveProcessedImage(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${tempDir.path}/processed_image_$timestamp.jpg';
    
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    
    return filePath;
  }
}