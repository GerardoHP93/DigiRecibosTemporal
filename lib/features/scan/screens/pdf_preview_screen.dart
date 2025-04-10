// lib/features/scan/screens/pdf_preview_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/pdf_preview_widget.dart';

class PdfPreviewScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista previa del PDF'),
        backgroundColor: const Color(0xFF1E555C),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onCancel,
        ),
      ),
      body: PdfPreviewWidget(
        pdfFile: pdfFile,
        onPagesSelected: onPagesSelected,
        onCancel: onCancel,
      ),
    );
  }
}