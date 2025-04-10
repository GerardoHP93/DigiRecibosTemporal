// lib/features/shared/widgets/scan_modal.dart

import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_strings.dart';
import 'package:digirecibos/features/scan/screens/preview_screen.dart';
import 'package:digirecibos/features/scan/screens/pdf_preview_screen.dart';
import 'package:digirecibos/features/scan/services/image_capture_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ScanModal extends StatelessWidget {
  final Function()? onClose;
  final ImageCaptureHandler _imageCaptureHandler = ImageCaptureHandler();

  ScanModal({
    Key? key,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.scanReceipt,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onClose ?? () => Navigator.of(context).pop(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tomar foto button
            _buildOptionButton(
              icon: Icons.camera_alt_outlined,
              label: AppStrings.takePhoto,
              onTap: () async {
                // Solicitar permiso de cámara
                await _requestCameraPermission(context);
              },
              context: context,
            ),
            const SizedBox(height: 16),
            // Cargar foto button
            _buildOptionButton(
              icon: Icons.image_outlined,
              label: AppStrings.uploadFromGallery,
              onTap: () async {
                // Solicitar permiso de almacenamiento y abrir galería
                await _pickImageFromGallery(context);
              },
              context: context,
            ),
            const SizedBox(height: 16),
            // Seleccionar PDF button
            _buildOptionButton(
              icon: Icons.insert_drive_file_outlined,
              label: AppStrings.selectPDF,
              onTap: () async {
                // Seleccionar archivo PDF
                await _pickPdfFile(context);
              },
              context: context,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestCameraPermission(BuildContext context) async {
    // Verificar el estado del permiso actual
    PermissionStatus cameraStatus = await Permission.camera.status;
    if (cameraStatus.isGranted) {
      // Si ya tiene permisos, abre directamente la cámara
      _takePhoto(context);
    } else if (cameraStatus.isDenied) {
      // Si el permiso está denegado, solicita permiso
      cameraStatus = await Permission.camera.request();
      if (cameraStatus.isGranted) {
        _takePhoto(context);
      } else {
        // Muestra diálogo informando que se necesita permiso
        _showPermissionDeniedDialog(context, 'cámara');
      }
    } else if (cameraStatus.isPermanentlyDenied) {
      // Si el permiso está permanentemente denegado, muestra diálogo para abrir configuración
      _showOpenSettingsDialog(context, 'cámara');
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        File imageFile = File(photo.path);
        
        // Cerrar el modal
        if (onClose != null) {
          onClose!();
        } else {
          Navigator.of(context).pop();
        }

        // Navegar a la pantalla de vista previa
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewScreen(
                imageFile: imageFile,
                onImageConfirmed: (File croppedImage) {
                  // Procesar la imagen confirmada con OCR
                  _imageCaptureHandler.processImage(context, croppedImage);
                },
                onCancel: () {
                  Navigator.of(context).pop(); // Volver atrás si cancela
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error al tomar la foto: $e');
      // Mostrar mensaje de error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al acceder a la cámara.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        File imageFile = File(image.path);
        
        // Cerrar el modal
        if (onClose != null) {
          onClose!();
        } else {
          Navigator.of(context).pop();
        }

        // Navegar a la pantalla de vista previa
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewScreen(
                imageFile: imageFile,
                onImageConfirmed: (File croppedImage) {
                  // Procesar la imagen confirmada con OCR
                  _imageCaptureHandler.processImage(context, croppedImage);
                },
                onCancel: () {
                  Navigator.of(context).pop(); // Volver atrás si cancela
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error al seleccionar la imagen: $e');
      // Mostrar mensaje de error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al acceder a la galería.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickPdfFile(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      // Usamos pickMedia para seleccionar cualquier tipo de archivo
      final XFile? result = await picker.pickMedia();

      if (result != null) {
        String filePath = result.path;
        // Verificar si es un PDF (extensión .pdf)
        if (filePath.toLowerCase().endsWith('.pdf')) {
          File pdfFile = File(filePath);
          
          // Cerrar el modal
          if (onClose != null) {
            onClose!();
          } else {
            Navigator.of(context).pop();
          }

          // Navegar a la pantalla de vista previa de PDF
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PdfPreviewScreen(
                  pdfFile: pdfFile,
                  onPagesSelected: (File pdf, List<int> selectedPages) {
                    // Procesar el PDF con las páginas seleccionadas
                    _imageCaptureHandler.processPdf(context, pdf, selectedPages);
                  },
                  onCancel: () {
                    Navigator.of(context).pop(); // Volver atrás si cancela
                  },
                ),
              ),
            );
          }
        } else {
          // No es un PDF
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor, selecciona un archivo PDF'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error al seleccionar el PDF: $e');
      // Mostrar mensaje de error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al acceder a los archivos.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showPermissionDeniedDialog(
      BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Permiso de $permissionType'),
          content: Text(
            'Para continuar, la aplicación necesita acceder a $permissionType. Por favor, concede el permiso cuando se te solicite.',
          ),
          actions: [
            TextButton(
              child: const Text('Entendido'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showOpenSettingsDialog(BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Permiso de $permissionType'),
          content: Text(
            'El permiso de $permissionType está permanentemente denegado. Por favor, abre la configuración de la aplicación y habilita el permiso.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Abrir Configuración'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}

// Función para mostrar el modal desde cualquier pantalla
void showScanModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    enableDrag: true,
    isDismissible: true,
    builder: (context) {
      return ScanModal(
        onClose: () => Navigator.of(context).pop(),
      );
    },
  );
}