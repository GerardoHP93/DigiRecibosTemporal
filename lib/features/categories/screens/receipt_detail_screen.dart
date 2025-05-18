// lib/features/categories/screens/receipt_detail_screen.dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/data/models/receipt.dart';
import 'package:digirecibos/data/repositories/receipt_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ReceiptDetailScreen extends StatefulWidget {
  final Receipt receipt;
  final Color categoryColor;

  const ReceiptDetailScreen({
    Key? key,
    required this.receipt,
    required this.categoryColor,
  }) : super(key: key);

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  final ReceiptRepository _receiptRepository = ReceiptRepository();
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Establecer orientación para pantalla completa
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restablecer orientación al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  // Métodos para acciones del recibo
  Future<void> _deleteReceipt() async {
    // Mostrar un diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar recibo'),
        content: const Text('¿Estás seguro de que deseas eliminar este recibo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      await _receiptRepository.deleteReceipt(widget.receipt);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recibo eliminado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error al eliminar el recibo: $e');
      setState(() {
        _isDeleting = false;
        _errorMessage = 'Error al eliminar el recibo';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Evita que el contenido se desplace cuando aparece el teclado
      appBar: AppBar(
        title: const Text('Detalle del recibo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_isDeleting)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteReceipt,
              tooltip: 'Eliminar recibo',
            ),
        ],
      ),
      body: _isDeleting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppDimens.paddingL),
                  Text('Eliminando recibo...'),
                ],
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    // Adaptación para diferentes tamaños de pantalla y texto
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360 || textScaleFactor > 1.3;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del recibo en formato de columna (modificado)
          _buildReceiptInfoColumn(isSmallScreen),
          
          // Previsualización del recibo
          Container(
            height: MediaQuery.of(context).size.height * 0.6, // Ajustar altura para dejar espacio
            padding: const EdgeInsets.only(bottom: AppDimens.paddingL),
            child: _buildReceiptPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptInfoColumn(bool isSmallScreen) {
    // Calcular el padding basado en si la pantalla es pequeña
    final EdgeInsets padding = isSmallScreen 
        ? const EdgeInsets.all(AppDimens.paddingM)
        : const EdgeInsets.all(AppDimens.paddingL);
    
    // Calcular el espacio vertical entre elementos basado en si la pantalla es pequeña
    final double verticalSpace = isSmallScreen 
        ? AppDimens.paddingS
        : AppDimens.paddingM;
        
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: AppDimens.elevationS,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monto en una línea completa
          Text(
            widget.receipt.formattedAmount,
            style: AppTextStyles.title.copyWith(
              color: AppColors.primary,
              fontSize: 24,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: verticalSpace),
          
          // Fecha en una línea aparte
          Text(
            widget.receipt.formattedDate,
            style: AppTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: verticalSpace),
          
          // Nombre del archivo en un contenedor decorado
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.paddingM,
              vertical: AppDimens.paddingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
            ),
            child: Text(
              widget.receipt.fileName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptPreview() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: AppDimens.paddingM),
              Text(
                _errorMessage!,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar PDF o imagen según el tipo
    if (widget.receipt.isPdf) {
      return _buildPdfPreview();
    } else {
      return _buildImagePreview();
    }
  }

  Widget _buildImagePreview() {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: CachedNetworkImage(
          imageUrl: widget.receipt.fileUrl,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.error, color: AppColors.error, size: 48),
          ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
  
  Widget _buildPdfPreview() {
    // Para PDF, tenemos que descargar primero el archivo desde la URL
    // y luego mostrarlo con PdfViewer.openFile
    return FutureBuilder<String>(
      future: _downloadPdfToTempFile(widget.receipt.fileUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: AppDimens.paddingM),
                Text(
                  'Error al cargar el PDF: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return PdfViewer.openFile(
            snapshot.data!,
            params: PdfViewerParams(
              pageNumber: 1,
            ),
          );
        } else {
          return const Center(
            child: Text('No se pudo cargar el PDF'),
          );
        }
      },
    );
  }

  // Método para descargar un PDF desde una URL y guardarlo en un archivo temporal
  Future<String> _downloadPdfToTempFile(String url) async {
    try {
      // Implementar utilizando flutter_cache_manager
      final cacheManager = DefaultCacheManager();
      final file = await cacheManager.getSingleFile(url);
      return file.path;
    } catch (e) {
      print('Error al descargar el PDF: $e');
      throw Exception('Error al descargar el PDF: $e');
    }
  }
}