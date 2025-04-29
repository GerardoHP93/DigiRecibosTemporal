// lib/features/analytics/services/chart_data_service.dart
import 'package:flutter/foundation.dart';
import 'package:digirecibos/data/models/receipt.dart';
import 'package:intl/intl.dart';

/// Servicio para procesar datos para las gráficas de costos
class ChartDataService {
  static final ChartDataService _instance = ChartDataService._internal();

  factory ChartDataService() {
    return _instance;
  }

  ChartDataService._internal();

  /// Procesa los recibos y los agrupa por mes para mostrar en gráficas
  /// Retorna un mapa con el formato {'Mes': monto total}
  Map<String, double> processReceiptsByMonth({
    required List<Receipt> receipts,
    required int? year,
    required int? startMonth,
    required int? endMonth,
  }) {
    try {
      debugPrint('Procesando ${receipts.length} recibos para gráficas');
      debugPrint('Filtros: Año=$year, Mes inicio=$startMonth, Mes fin=$endMonth');

      // Verificar si hay recibos
      if (receipts.isEmpty) {
        debugPrint('No hay recibos para procesar');
        return {};
      }

      // Inicializar el mapa de resultado con todos los meses en cero
      // para asegurar que todos los meses aparezcan en la gráfica
      final Map<String, double> monthlyData = _initializeMonthsMap(startMonth, endMonth);
      
      // Filtrar recibos por año si es necesario
      List<Receipt> filteredReceipts = receipts;
      if (year != null) {
        filteredReceipts = receipts
            .where((receipt) => receipt.date.year == year)
            .toList();
        debugPrint('Filtrando por año $year: ${filteredReceipts.length} recibos');
      }

      // Filtrar recibos por rango de meses si es necesario
      if (startMonth != null && endMonth != null) {
        filteredReceipts = filteredReceipts
            .where((receipt) => 
                receipt.date.month >= startMonth &&
                receipt.date.month <= endMonth)
            .toList();
        debugPrint('Filtrando por meses $startMonth-$endMonth: ${filteredReceipts.length} recibos');
      }

      // Agrupar los recibos por mes y calcular la suma
      for (var receipt in filteredReceipts) {
        // Obtener el nombre del mes
        final monthName = _getMonthName(receipt.date.month);
        
        // Sumar el monto al mes correspondiente
        if (monthlyData.containsKey(monthName)) {
          monthlyData[monthName] = (monthlyData[monthName] ?? 0) + receipt.amount;
        } else {
          monthlyData[monthName] = receipt.amount;
        }
      }

      debugPrint('Datos procesados: $monthlyData');
      return monthlyData;
    } catch (e) {
      debugPrint('Error procesando recibos para gráficas: $e');
      return {};
    }
  }

  /// Calcula la suma total de los montos filtrados
  double calculateTotalAmount({
    required List<Receipt> receipts,
    required int? year,
    required int? startMonth,
    required int? endMonth,
  }) {
    try {
      double total = 0;
      
      // Filtrar por año si es necesario
      List<Receipt> filteredReceipts = receipts;
      if (year != null) {
        filteredReceipts = receipts
            .where((receipt) => receipt.date.year == year)
            .toList();
      }

      // Filtrar por rango de meses si es necesario
      if (startMonth != null && endMonth != null) {
        filteredReceipts = filteredReceipts
            .where((receipt) => 
                receipt.date.month >= startMonth &&
                receipt.date.month <= endMonth)
            .toList();
      }

      // Sumar todos los montos
      for (var receipt in filteredReceipts) {
        total += receipt.amount;
      }

      debugPrint('Suma total calculada: $total');
      return total;
    } catch (e) {
      debugPrint('Error calculando suma total: $e');
      return 0;
    }
  }

  /// Obtiene una lista de años disponibles a partir de los recibos
  List<int> getAvailableYears(List<Receipt> receipts) {
    try {
      final Set<int> years = {};
      
      for (var receipt in receipts) {
        years.add(receipt.date.year);
      }
      
      // Ordenar los años de más reciente a más antiguo
      final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
      
      // Si no hay años disponibles, añadir el año actual
      if (sortedYears.isEmpty) {
        sortedYears.add(DateTime.now().year);
      }
      
      debugPrint('Años disponibles: $sortedYears');
      return sortedYears;
    } catch (e) {
      debugPrint('Error obteniendo años disponibles: $e');
      return [DateTime.now().year];
    }
  }

  /// Determina el año con más recibos
  int getMostFrequentYear(List<Receipt> receipts) {
    try {
      if (receipts.isEmpty) {
        return DateTime.now().year;
      }
      
      // Contar recibos por año
      final Map<int, int> yearCounts = {};
      
      for (var receipt in receipts) {
        final year = receipt.date.year;
        yearCounts[year] = (yearCounts[year] ?? 0) + 1;
      }
      
      // Encontrar el año con más recibos
      int mostFrequentYear = DateTime.now().year;
      int maxCount = 0;
      
      yearCounts.forEach((year, count) {
        if (count > maxCount) {
          maxCount = count;
          mostFrequentYear = year;
        }
      });
      
      debugPrint('Año con más recibos: $mostFrequentYear (${yearCounts[mostFrequentYear] ?? 0} recibos)');
      return mostFrequentYear;
    } catch (e) {
      debugPrint('Error determinando el año más frecuente: $e');
      return DateTime.now().year;
    }
  }

  /// Inicializa un mapa con todos los meses del año con valor 0
  Map<String, double> _initializeMonthsMap(int? startMonth, int? endMonth) {
    final Map<String, double> monthsMap = {};
    
    // Si no hay rango de meses definido, incluir todos los meses
    final int start = startMonth ?? 1;
    final int end = endMonth ?? 12;
    
    for (int i = start; i <= end; i++) {
      final monthName = _getMonthName(i);
      monthsMap[monthName] = 0;
    }
    
    return monthsMap;
  }

  /// Convierte el número del mes a su nombre abreviado
  String _getMonthName(int month) {
    // Asegurar que el mes está en el rango válido
    month = month.clamp(1, 12);
    
    // Usar DateFormat para obtener el nombre del mes
    final date = DateTime(2022, month, 1);
    return DateFormat('MMM').format(date);
  }
}