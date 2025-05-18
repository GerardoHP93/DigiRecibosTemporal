// lib/features/scan/screens/pdf_preview_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/pdf_preview_widget.dart';

class PdfPreviewScreen extends StatefulWidget {
  final File pdfFile;
  final Function(File, List<int>) onPagesSelected;
  final VoidCallback onCancel;

  const PdfPreviewScreen({
    Key? key,
    required this.pdfFile,
    required this.onPagesSelected,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  // Referencia al widget hijo mediante una clave global
  final previewWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    debugPrint('PdfPreviewScreen inicializada');
  }
  
  @override
  void didUpdateWidget(covariant PdfPreviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('PdfPreviewScreen didUpdateWidget - posible regreso desde otra pantalla');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Interceptar el botón de retroceso para asegurar que el estado se restablece correctamente
      onWillPop: () async {
        debugPrint('WillPopScope - Saliendo de PdfPreviewScreen');
        widget.onCancel();
        return false; // La navegación será manejada por onCancel
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vista previa del PDF'),
          backgroundColor: const Color(0xFF1E555C),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onCancel,
          ),
        ),
        body: PdfPreviewWidget(
          key: previewWidgetKey,
          pdfFile: widget.pdfFile,
          onPagesSelected: (file, pages) {
            debugPrint('onPagesSelected llamado en PdfPreviewScreen');
            widget.onPagesSelected(file, pages);
          },
          onCancel: () {
            debugPrint('onCancel llamado en PdfPreviewScreen');
            widget.onCancel();
          },
        ),
      ),
    );
  }
}