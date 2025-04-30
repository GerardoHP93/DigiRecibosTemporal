// lib/features/analytics/widgets/expense_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> monthlyData;
  final Color barColor;
  final double maxY;

  const ExpenseChart({
    Key? key,
    required this.monthlyData,
    required this.barColor,
    required this.maxY,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si no hay datos, mostrar mensaje
    if (monthlyData.isEmpty) {
      return _buildEmptyChart();
    }

    // Tamaño de pantalla para responsividad
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    
    // Determinar la relación de aspecto basada en el número de datos y tamaño de pantalla
    final int numMonths = monthlyData.length;
    final double aspectRatio = _calculateAspectRatio(screenWidth, screenHeight, numMonths);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(
        horizontal: AppDimens.paddingL,
        vertical: AppDimens.paddingM,
      ),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingL),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY * 1.1, // 10% de espacio extra arriba para mejor visualización (reducido de 20%)
              minY: 0, // Asegurar que la gráfica comience desde 0
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    // Obtener el nombre del mes y el valor
                    final monthNames = monthlyData.keys.toList();
                    if (groupIndex < 0 || groupIndex >= monthNames.length) {
                      return null;
                    }
                    final month = monthNames[groupIndex];
                    final value = rod.toY;
                    
                    return BarTooltipItem(
                      '$month: \$${value.toStringAsFixed(2)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final monthNames = monthlyData.keys.toList();
                      if (value < 0 || value >= monthNames.length) {
                        return const SizedBox.shrink();
                      }
                      
                      // Formato para dispositivos pequeños
                      if (isMobile && monthNames.length > 6) {
                        // Si hay muchos meses, mostrar solo algunos
                        if (value.toInt() % 2 != 0 && value.toInt() != monthNames.length - 1) {
                          return const SizedBox.shrink();
                        }
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(top: AppDimens.paddingS),
                        child: Text(
                          monthNames[value.toInt()],
                          style: AppTextStyles.chartLabel,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      // Ajustar intervalos para mayor granularidad
                      final double interval = _calculateYAxisInterval(maxY);
                      if (value % interval != 0 && value != maxY) {
                        return const SizedBox.shrink();
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: AppDimens.paddingS),
                        child: Text(
                          value.toInt().toString(),
                          style: AppTextStyles.chartLabel,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              gridData: FlGridData(
                show: true,
                horizontalInterval: _calculateYAxisInterval(maxY), // Intervalo dinámico
                getDrawingHorizontalLine: _getDrawingLine,
                drawVerticalLine: false,
              ),
              barGroups: _createBarGroups(),
            ),
            swapAnimationDuration: const Duration(milliseconds: 500),
            swapAnimationCurve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }

  // Función para calcular la relación de aspecto ideal basada en el número de meses y tamaño de pantalla
  double _calculateAspectRatio(double screenWidth, double screenHeight, int numMonths) {
    debugPrint('Calculando aspect ratio: ancho=$screenWidth, alto=$screenHeight, meses=$numMonths');
    
    // Factor base de aspecto
    double baseAspect = 1.5;
    
    // Ajustar según cantidad de meses
    if (numMonths > 6) {
      // Si hay muchos meses, hacer la gráfica más ancha
      baseAspect = 1.2;
    } else if (numMonths <= 3) {
      // Si hay pocos meses, hacer la gráfica más alta
      baseAspect = 1.7;
    }
    
    // Ajustar según el tamaño de pantalla
    if (screenWidth < 360) {
      // Pantallas muy pequeñas
      baseAspect = baseAspect * 0.9;
    } else if (screenHeight > 800) {
      // Pantallas altas
      baseAspect = baseAspect * 0.8;
    }
    
    debugPrint('Aspect ratio calculado: $baseAspect');
    return baseAspect;
  }
  
  // Calcula un intervalo óptimo para el eje Y basado en el valor máximo
  double _calculateYAxisInterval(double maxValue) {
    debugPrint('Calculando intervalo para valor máximo: $maxValue');
    
    if (maxValue <= 100) {
      return 20.0; // Intervalos de 20 para valores pequeños
    } else if (maxValue <= 500) {
      return 50.0; // Intervalos de 50 para valores medianos
    } else if (maxValue <= 1000) {
      return 100.0; // Intervalos de 100 para valores moderados
    } else if (maxValue <= 5000) {
      return 500.0; // Intervalos de 500 para valores grandes
    } else if (maxValue <= 10000) {
      return 1000.0; // Intervalos de 1000 para valores muy grandes
    } else {
      // Para valores extremadamente grandes, usar múltiplos de 2000
      return 2000.0;
    }
  }

  // Función para crear líneas horizontales de la cuadrícula
  static FlLine _getDrawingLine(double value) {
    return FlLine(
      color: AppColors.border.withOpacity(0.3),
      strokeWidth: 1,
      dashArray: [5, 5],
    );
  }

  // Crea los grupos de barras para el gráfico
  List<BarChartGroupData> _createBarGroups() {
    final List<BarChartGroupData> barGroups = [];
    final months = monthlyData.keys.toList();
    
    // Calcular ancho de barras basado en número de meses
    double barWidth = 22;
    if (months.length > 6) {
      barWidth = 18; // Barras más delgadas si hay muchos meses
    } else if (months.length <= 3) {
      barWidth = 26; // Barras más anchas si hay pocos meses
    }
    
    for (int i = 0; i < months.length; i++) {
      final String month = months[i];
      final double value = monthlyData[month] ?? 0;
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: barColor.withOpacity(0.7),
              width: barWidth,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimens.radiusS),
                topRight: Radius.circular(AppDimens.radiusS),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY * 1.1, // Ajustar al mismo valor que maxY en BarChartData
                color: AppColors.border.withOpacity(0.1),
              ),
            ),
          ],
        ),
      );
    }
    
    return barGroups;
  }

  // Widget para mostrar cuando no hay datos
  Widget _buildEmptyChart() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(AppDimens.paddingL),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.insert_chart_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimens.paddingM),
          Text(
            'No hay datos para mostrar',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}