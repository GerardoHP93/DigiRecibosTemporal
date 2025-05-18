// lib/features/scan/models/receipt_data.dart

class ReceiptData {
  /// Monto extraído del recibo
  final double? amount;
 
  /// Fecha extraída del recibo
  final DateTime? date;
 
  /// Texto completo reconocido por OCR
  final String rawText;
 
  /// Indica si el procesamiento fue exitoso
  final bool success;
 
  /// Mensaje de error en caso de fallo
  final String? errorMessage;
  
  /// Descripción opcional ingresada por el usuario
  final String? description;

  ReceiptData({
    this.amount,
    this.date,
    required this.rawText,
    required this.success,
    this.errorMessage,
    this.description,
  });

  /// Formatea el monto para mostrar (con dos decimales)
  String? get formattedAmount {
    if (amount == null) return null;
    return '\$${amount!.toStringAsFixed(2)}';
  }

  /// Formatea la fecha para mostrar (dd/MM/yyyy)
  String? get formattedDate {
    if (date == null) return null;
    return '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}';
  }

  /// Crea una copia del objeto con valores modificados
  ReceiptData copyWith({
    double? amount,
    DateTime? date,
    String? rawText,
    bool? success,
    String? errorMessage,
    String? description,
  }) {
    return ReceiptData(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      rawText: rawText ?? this.rawText,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'ReceiptData(amount: $formattedAmount, date: $formattedDate, success: $success, description: ${description != null ? "Sí" : "No"})';
  }
}