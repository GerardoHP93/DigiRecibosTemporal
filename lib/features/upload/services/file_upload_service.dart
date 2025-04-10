// lib/features/upload/services/file_upload_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Servicio para subir archivos a Firebase Storage
class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  /// Singleton pattern
  factory FileUploadService() {
    return _instance;
  }

  FileUploadService._internal();

  /// Sube un archivo a Firebase Storage y devuelve la URL de descarga
  Future<String> uploadFile(File file, String categoryId) async {
    try {
      // Verificar si el usuario está autenticado
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado.');
      }

      // Generar un nombre de archivo único basado en UUID
      final fileName = '${_uuid.v4()}${path.extension(file.path)}';
      
      // Crear la ruta en Storage: users/[userId]/categories/[categoryId]/[fileName]
      final storagePath = 'users/${user.uid}/categories/$categoryId/$fileName';
      
      // Referencia al archivo en Storage
      final storageRef = _storage.ref().child(storagePath);
      
      // Iniciar la carga
      final uploadTask = storageRef.putFile(file);
      
      // Escuchar progreso de carga (para implementaciones futuras de barra de progreso)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Progreso de carga: ${(progress * 100).toStringAsFixed(2)}%');
      });
      
      // Esperar a que se complete la carga y obtener la URL de descarga
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (error) {
      debugPrint('Error al subir el archivo: $error');
      throw Exception('Error al subir el archivo: $error');
    }
  }

  /// Elimina un archivo de Firebase Storage basado en su URL
  Future<void> deleteFile(String fileUrl) async {
    try {
      // Obtener referencia desde la URL
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (error) {
      debugPrint('Error al eliminar el archivo: $error');
      throw Exception('Error al eliminar el archivo: $error');
    }
  }
}