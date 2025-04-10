// lib/data/repositories/receipt_repository.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digirecibos/data/models/receipt.dart';
import 'package:digirecibos/features/scan/models/receipt_data.dart';
import 'package:digirecibos/features/upload/services/file_upload_service.dart';
import 'package:path/path.dart' as path;

/// Repositorio para gestionar recibos en Firestore
class ReceiptRepository {
  static final ReceiptRepository _instance = ReceiptRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FileUploadService _fileUploadService = FileUploadService();

  /// Singleton pattern
  factory ReceiptRepository() {
    return _instance;
  }

  ReceiptRepository._internal();

  /// Obtiene la colección de recibos
  CollectionReference get _receiptsCollection =>
      _firestore.collection('receipts');

  /// Subir un recibo nuevo con su archivo
  Future<Receipt> uploadReceipt({
    required String categoryId,
    required ReceiptData receiptData,
    required File file,
  }) async {
    try {
      // Verificar si el usuario está autenticado
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado.');
      }

      // Subir el archivo a Firebase Storage
      final fileUrl = await _fileUploadService.uploadFile(file, categoryId);

      // Determinar el tipo de archivo
      final fileName = path.basename(file.path);
      final fileType =
          path.extension(file.path).toLowerCase() == '.pdf' ? 'pdf' : 'image';

      // Crear el documento del recibo
      final receiptDoc = _receiptsCollection.doc();

      // Datos del recibo
      final receipt = Receipt(
        id: receiptDoc.id,
        categoryId: categoryId,
        userId: user.uid,
        fileName: fileName,
        fileUrl: fileUrl,
        fileType: fileType,
        amount: receiptData.amount ?? 0.0,
        date: receiptData.date ?? DateTime.now(),
        createdAt: DateTime.now(),
        rawText: receiptData.rawText,
      );

      // Guardar en Firestore
      await receiptDoc.set(receipt.toFirestore());

      return receipt;
    } catch (error) {
      debugPrint('Error al subir el recibo: $error');
      throw Exception('Error al subir el recibo: $error');
    }
  }

  /// Obtener recibos por categoría

  /// Obtener recibos por categoría
  Stream<List<Receipt>> getReceiptsByCategory(String categoryId) {
    try {
      // Verificar si el usuario está autenticado
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado.');
      }

      debugPrint(
          'Obteniendo recibos para categoría: $categoryId y usuario: ${user.uid}');

      // Asegurarse de que la consulta sea específica y no recupere duplicados
      // Usando .snapshots().map() para transformar los documentos en objetos Receipt
      return _receiptsCollection
          .where('userId', isEqualTo: user.uid)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        debugPrint('Recibidos ${snapshot.docs.length} documentos de Firestore');

        // Convertir documentos a lista de Receipt y verificar duplicados por ID
        final List<Receipt> receipts = [];
        final Set<String> receiptIds = {}; // Conjunto para track de IDs

        for (var doc in snapshot.docs) {
          final receipt = Receipt.fromFirestore(doc);
          // Solo agregar si no existe ya en la lista (evitar duplicados)
          if (!receiptIds.contains(receipt.id)) {
            receiptIds.add(receipt.id);
            receipts.add(receipt);
            debugPrint(
                'Procesado recibo: ID=${receipt.id}, Fecha=${receipt.formattedDate}, Monto=${receipt.formattedAmount}');
          }
        }

        return receipts;
      }).handleError((error) {
        debugPrint('Error en stream de recibos: $error');
        // Propagamos el error para que pueda ser manejado por el listener
        throw error;
      });
    } catch (error) {
      debugPrint('Error al obtener recibos: $error');
      // Crear un stream que emita un error
      return Stream.error(error);
    }
  }

  /// Obtener un recibo por su ID
  Future<Receipt?> getReceiptById(String receiptId) async {
    try {
      final doc = await _receiptsCollection.doc(receiptId).get();
      if (!doc.exists) {
        return null;
      }
      return Receipt.fromFirestore(doc);
    } catch (error) {
      debugPrint('Error al obtener el recibo: $error');
      throw Exception('Error al obtener el recibo: $error');
    }
  }

  /// Actualizar un recibo
  Future<void> updateReceipt(Receipt receipt) async {
    try {
      await _receiptsCollection.doc(receipt.id).update(receipt.toFirestore());
    } catch (error) {
      debugPrint('Error al actualizar el recibo: $error');
      throw Exception('Error al actualizar el recibo: $error');
    }
  }

  /// Eliminar un recibo
  Future<void> deleteReceipt(Receipt receipt) async {
    try {
      // Eliminar el archivo de Storage
      await _fileUploadService.deleteFile(receipt.fileUrl);

      // Eliminar el documento de Firestore
      await _receiptsCollection.doc(receipt.id).delete();
    } catch (error) {
      debugPrint('Error al eliminar el recibo: $error');
      throw Exception('Error al eliminar el recibo: $error');
    }
  }
}
