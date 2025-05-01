// lib/features/scan/widgets/image_cropper_widget.dart

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class ImageCropperWidget extends StatefulWidget {
  final File imageFile;
  final Function(File) onCropped;
  final VoidCallback onCancel;

  const ImageCropperWidget({
    Key? key,
    required this.imageFile,
    required this.onCropped,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<ImageCropperWidget> createState() => _ImageCropperWidgetState();
}

class _ImageCropperWidgetState extends State<ImageCropperWidget> {
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen a recortar
        Positioned.fill(
          child: Image.file(
            widget.imageFile,
            fit: BoxFit.contain,
          ),
        ),
        
        // Controles
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón de cancelar
              ElevatedButton.icon(
                onPressed: _isCropping ? null : widget.onCancel,
                icon: const Icon(Icons.close),
                label: const Text('Cancelar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              
              // Botón de recortar
              ElevatedButton.icon(
                onPressed: _isCropping ? null : _cropImage,
                icon: const Icon(Icons.crop),
                label: _isCropping 
                    ? const Text('Procesando...') 
                    : const Text('Recortar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E555C),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Indicador de carga
        if (_isCropping)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1E555C),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _cropImage() async {
    try {
      setState(() {
        _isCropping = true;
      });
      
      debugPrint('Iniciando recorte de imagen: ${widget.imageFile.path}');

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar recibo',
            toolbarColor: const Color(0xFF1E555C),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Recortar recibo',
            doneButtonTitle: 'Listo',
            cancelButtonTitle: 'Cancelar',
          ),
        ],
      );

      // Importante: Asegurarnos de que _isCropping se establezca a false
      // independientemente del resultado
      setState(() {
        _isCropping = false;
      });

      if (croppedFile != null) {
        final croppedImage = File(croppedFile.path);
        debugPrint('Imagen recortada exitosamente: ${croppedImage.path}');
        widget.onCropped(croppedImage);
      } else {
        // El usuario canceló el recorte
        debugPrint('Recorte de imagen cancelado por el usuario');
      }
    } catch (e) {
      debugPrint('Error al recortar la imagen: $e');
      // Asegurarnos de establecer _isCropping a false incluso si hay un error
      setState(() {
        _isCropping = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al procesar la imagen'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}