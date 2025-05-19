// lib/features/export/services/csv_export_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:digirecibos/data/models/receipt.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

/// Servicio para exportar datos de recibos a formato CSV
class CsvExportService {
  static final CsvExportService _instance = CsvExportService._internal();

  // Singleton pattern
  factory CsvExportService() {
    return _instance;
  }

  CsvExportService._internal();

  /// Exporta recibos a un archivo CSV y lo comparte
  Future<void> exportReceiptsToCSV({
    required List<Receipt> receipts,
    required String categoryName,
  }) async {
    try {
      // Verificar si hay recibos para exportar
      if (receipts.isEmpty) {
        throw Exception('No hay recibos para exportar');
      }

      debugPrint('Iniciando exportación de ${receipts.length} recibos para categoría: $categoryName');

      // Ordenar recibos por fecha (de más antiguo a más reciente)
      final sortedReceipts = List<Receipt>.from(receipts);
      sortedReceipts.sort((a, b) => a.date.compareTo(b.date));

      // Generar contenido CSV
      final csvContent = _generateCSVContent(sortedReceipts, categoryName);

      // Crear archivo
      final file = await _saveCSVToFile(csvContent, categoryName);

      // Compartir archivo
      await _shareCSVFile(file);

      debugPrint('Exportación CSV completada con éxito: ${file.path}');
    } catch (e) {
      debugPrint('Error en exportación CSV: $e');
      rethrow; // Re-lanzar para manejar el error en la UI
    }
  }

  /// Genera el contenido del archivo CSV
  String _generateCSVContent(List<Receipt> receipts, String categoryName) {
    try {
      final StringBuffer buffer = StringBuffer();
      
      // Encabezado
      buffer.writeln('Reporte de recibos - Categoría: $categoryName');
      buffer.writeln('Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      buffer.writeln('');
      
      // Encabezados de columnas
      buffer.writeln('Fecha,Monto,Descripción');
      
      // Agrupar recibos por año y luego por mes
      final receiptsByYear = _groupReceiptsByYear(receipts);
      
      // Para cada año
      for (var year in receiptsByYear.keys.toList()..sort()) {
        final yearReceipts = receiptsByYear[year]!;
        
        // Encabezado del año
        buffer.writeln('');
        buffer.writeln('AÑO $year');
        
        // Agrupar por mes dentro del año
        final receiptsByMonth = _groupReceiptsByMonth(yearReceipts);
        double yearTotal = 0;
        
        // Para cada mes dentro del año
        for (var monthKey in receiptsByMonth.keys.toList()..sort()) {
          final monthReceipts = receiptsByMonth[monthKey]!;
          final month = _getMonthName(int.parse(monthKey));
          
          // Encabezado del mes
          buffer.writeln('');
          buffer.writeln('$month $year');
          
          // Datos de recibos de este mes
          double monthTotal = 0;
          for (var receipt in monthReceipts) {
            // Formatear fecha como DD/MM/YYYY
            final formattedDate = DateFormat('dd/MM/yyyy').format(receipt.date);
            
            // Formatear monto con 2 decimales (usando punto como separador decimal)
            final formattedAmount = receipt.amount.toStringAsFixed(2);
            
            // Procesar descripción (escapar comas, comillas, etc.)
            final sanitizedDescription = receipt.description != null && receipt.description!.isNotEmpty 
                ? '"${receipt.description!.replaceAll('"', '""')}"' 
                : '""';
            
            buffer.writeln('$formattedDate,$formattedAmount,$sanitizedDescription');
            
            // Acumular para subtotal del mes
            monthTotal += receipt.amount;
          }
          
          // Subtotal del mes
          buffer.writeln('Subtotal $month $year,${monthTotal.toStringAsFixed(2)},');
          
          // Acumular para el total del año
          yearTotal += monthTotal;
        }
        
        // Total del año
        buffer.writeln('');
        buffer.writeln('TOTAL AÑO $year,${yearTotal.toStringAsFixed(2)},');
      }
      
      // Total general
      final totalAmount = receipts.fold<double>(0, (total, receipt) => total + receipt.amount);
      buffer.writeln('');
      buffer.writeln('TOTAL GENERAL,${totalAmount.toStringAsFixed(2)},');
      
      return buffer.toString();
    } catch (e) {
      debugPrint('Error al generar contenido CSV: $e');
      throw Exception('Error al generar contenido CSV: $e');
    }
  }

  /// Agrupa recibos por año
  Map<String, List<Receipt>> _groupReceiptsByYear(List<Receipt> receipts) {
    final Map<String, List<Receipt>> result = {};
    
    for (var receipt in receipts) {
      final year = receipt.date.year.toString();
      
      if (!result.containsKey(year)) {
        result[year] = [];
      }
      
      result[year]!.add(receipt);
    }
    
    return result;
  }

  /// Agrupa recibos por mes
  Map<String, List<Receipt>> _groupReceiptsByMonth(List<Receipt> receipts) {
    final Map<String, List<Receipt>> result = {};
    
    for (var receipt in receipts) {
      final month = receipt.date.month.toString().padLeft(2, '0');
      
      if (!result.containsKey(month)) {
        result[month] = [];
      }
      
      result[month]!.add(receipt);
    }
    
    return result;
  }

  /// Obtiene el nombre del mes a partir del número
  String _getMonthName(int month) {
    try {
      // Usar DateFormat para obtener el nombre del mes
      final monthDate = DateTime(2022, month);
      return DateFormat('MMMM', 'es').format(monthDate).toUpperCase();
    } catch (e) {
      // Si hay error, usar nombre simple
      const months = [
        '', 'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO', 
        'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE'
      ];
      return month >= 1 && month <= 12 ? months[month] : 'MES $month';
    }
  }

  /// Guarda el contenido CSV en un archivo
  Future<File> _saveCSVToFile(String content, String categoryName) async {
    try {
      // Sanitizar nombre de categoría para nombre de archivo
      final safeCategoryName = categoryName
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^\w]'), '');
      
      // Crear nombre de archivo
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'recibos_${safeCategoryName}_$timestamp.csv';
      
      // Obtener directorio
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      
      debugPrint('Guardando archivo CSV en: $filePath');
      
      // Crear y escribir archivo
      final file = File(filePath);
      await file.writeAsString(content);
      
      return file;
    } catch (e) {
      debugPrint('Error al guardar archivo CSV: $e');
      throw Exception('Error al guardar archivo CSV: $e');
    }
  }

  /// Comparte el archivo CSV generado
  Future<void> _shareCSVFile(File file) async {
    try {
      debugPrint('Preparando para compartir archivo: ${file.path}');
      
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Reporte de recibos DigiRecibos',
        text: 'Reporte generado desde DigiRecibos',
      );
      
      debugPrint('Resultado de compartir: ${result.status}');
    } catch (e) {
      debugPrint('Error al compartir archivo: $e');
      throw Exception('Error al compartir archivo: $e');
    }
  }
}