// lib/data/models/receipt.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Receipt {
  /// ID único del recibo
  final String id;
  
  /// Categoría a la que pertenece el recibo
  final String categoryId;
  
  /// ID del usuario propietario del recibo
  final String userId;
  
  /// Nombre del archivo para mostrar
  final String fileName;
  
  /// URL del archivo en Firebase Storage
  final String fileUrl;
  
  /// Tipo de archivo (imagen o PDF)
  final String fileType;
  
  /// Monto extraído del recibo
  final double amount;
  
  /// Fecha del recibo
  final DateTime date;
  
  /// Fecha de creación del registro
  final DateTime createdAt;
  
  /// Texto completo extraído por OCR (opcional)
  final String? rawText;
  
  /// Descripción opcional del recibo
  final String? description;

  Receipt({
    required this.id,
    required this.categoryId,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.rawText,
    this.description,
  });

  /// Crear un objeto Receipt desde un documento de Firestore
  factory Receipt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Receipt(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      userId: data['userId'] ?? '',
      fileName: data['fileName'] ?? 'Recibo sin nombre',
      fileUrl: data['fileUrl'] ?? '',
      fileType: data['fileType'] ?? 'image',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      rawText: data['rawText'],
      description: data['description'],
    );
  }

  /// Convertir el objeto Receipt a un Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'userId': userId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'rawText': rawText,
      'description': description,
    };
  }

  /// Obtener la extensión del archivo basado en su URL
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Determinar si el archivo es un PDF
  bool get isPdf => fileType.toLowerCase() == 'pdf' || 
                    fileExtension == 'pdf';

  /// Obtener el nombre formateado para mostrar
  String get displayName {
    // Si el nombre es muy largo, truncarlo
    if (fileName.length > 25) {
      return '${fileName.substring(0, 22)}...';
    }
    return fileName;
  }

  /// Formatear el monto para mostrar
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  /// Formatear la fecha para mostrar (dd/MM/yyyy)
  String get formattedDate => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  /// Crear una copia del objeto con valores modificados
  Receipt copyWith({
    String? id,
    String? categoryId,
    String? userId,
    String? fileName,
    String? fileUrl,
    String? fileType,
    double? amount,
    DateTime? date,
    DateTime? createdAt,
    String? rawText,
    String? description,
  }) {
    return Receipt(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      rawText: rawText ?? this.rawText,
      description: description ?? this.description,
    );
  }
}