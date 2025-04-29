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
    final isMobile = screenWidth < 600;
    
    return AspectRatio(
      aspectRatio: isMobile ? 1.2 : 1.7,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY * 1.2, // 20% de espacio extra arriba para mejor visualización
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
                    // No mostrar demasiados valores en el eje Y
                    if (value % 100 != 0 && value != maxY) {
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
            gridData: const FlGridData(
              show: true,
              horizontalInterval: 100,
              getDrawingHorizontalLine: _getDrawingLine,
              drawVerticalLine: false,
            ),
            barGroups: _createBarGroups(),
          ),
          swapAnimationDuration: const Duration(milliseconds: 500),
          swapAnimationCurve: Curves.easeInOut,
        ),
      ),
    );
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
              width: 22,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimens.radiusS),
                topRight: Radius.circular(AppDimens.radiusS),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY * 1.2,
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
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.insert_chart_outlined, // Cambiado por un icono disponible
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