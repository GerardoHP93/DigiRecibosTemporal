// lib/features/scan/screens/preview_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/image_cropper_widget.dart';

class PreviewScreen extends StatefulWidget {
  final File imageFile;
  final Function(File) onImageConfirmed;
  final VoidCallback onCancel;

  const PreviewScreen({
    Key? key,
    required this.imageFile,
    required this.onImageConfirmed,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late File _currentImage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.imageFile;
    debugPrint('PreviewScreen inicializada con imagen: ${_currentImage.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista previa'),
        backgroundColor: const Color(0xFF1E555C),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isProcessing ? null : widget.onCancel,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isProcessing ? null : () => widget.onImageConfirmed(_currentImage),
            tooltip: 'Confirmar',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Widget de recorte de imagen
          Positioned.fill(
            child: ImageCropperWidget(
              imageFile: _currentImage,
              onCropped: (File croppedImage) {
                debugPrint('Imagen recortada recibida: ${croppedImage.path}');
                setState(() {
                  _currentImage = croppedImage;
                  // Importante: Asegurarnos de que _isProcessing se establezca a false
                  // después de recibir la imagen recortada
                  _isProcessing = false;
                });
              },
              onCancel: widget.onCancel,
            ),
          ),
          
          // Overlay de instrucciones
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Ajusta la imagen para que el recibo esté visible y bien encuadrado. Esto mejorará la precisión del reconocimiento de texto.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Indicador de carga
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF1E555C)),
                    SizedBox(height: 16),
                    Text(
                      'Procesando imagen...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : widget.onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing 
                      ? null 
                      : () => widget.onImageConfirmed(_currentImage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E555C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}