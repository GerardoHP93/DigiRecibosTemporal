// lib/features/export/widgets/export_report_button.dart
import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/data/models/receipt.dart';
import 'package:digirecibos/features/export/services/csv_export_service.dart';

class ExportReportButton extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final List<Receipt> receipts;

  const ExportReportButton({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.receipts,
  }) : super(key: key);

  @override
  State<ExportReportButton> createState() => _ExportReportButtonState();
}

class _ExportReportButtonState extends State<ExportReportButton> {
  final CsvExportService _exportService = CsvExportService();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    // Adaptación a diferentes tamaños de pantalla
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final double iconSize = isSmallScreen ? 24 : 32;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.paddingL,
        vertical: AppDimens.paddingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Alinear a la izquierda (contrario a ViewChartsButton)
        children: [
          GestureDetector(
            onTap: _isExporting ? null : _exportReport,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Exportar\nreporte",
                  style: AppTextStyles.chartLabel,
                ),
                const SizedBox(height: AppDimens.paddingXS),
                Container(
                  padding: EdgeInsets.all(AppDimens.paddingS),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusL),
                  ),
                  child: _isExporting
                      ? SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(Icons.file_download, size: iconSize),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportReport() async {
    // Verificar que haya recibos para exportar
    if (widget.receipts.isEmpty) {
      _showSnackbar('No hay recibos para exportar');
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      debugPrint('Iniciando exportación para categoría: ${widget.categoryName}');
      await _exportService.exportReceiptsToCSV(
        receipts: widget.receipts,
        categoryName: widget.categoryName,
      );
      
      if (mounted) {
        _showSnackbar('Reporte generado correctamente');
      }
    } catch (e) {
      debugPrint('Error al exportar reporte: $e');
      if (mounted) {
        _showSnackbar('Error al exportar reporte: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}