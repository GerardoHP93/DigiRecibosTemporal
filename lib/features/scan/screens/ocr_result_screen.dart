// lib/features/scan/screens/ocr_result_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_strings.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/features/scan/models/receipt_data.dart';
import 'package:digirecibos/shared/widgets/decorative_background.dart';
import 'package:digirecibos/features/scan/screens/category_selection_screen.dart';

class OcrResultScreen extends StatefulWidget {
  final ReceiptData receiptData;
  final String filePath;

  const OcrResultScreen({
    Key? key,
    required this.receiptData,
    required this.filePath,
  }) : super(key: key);

  @override
  State<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends State<OcrResultScreen> {
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores con los datos extraídos
    _amountController = TextEditingController(
      text: widget.receiptData.amount != null 
        ? widget.receiptData.amount!.toString() 
        : ''
    );
    
    // Formatear la fecha si está disponible
    if (widget.receiptData.date != null) {
      _selectedDate = widget.receiptData.date;
      _dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(widget.receiptData.date!)
      );
    } else {
      _dateController = TextEditingController();
    }
    
    // Inicializar controlador para la descripción
    _descriptionController = TextEditingController(
      text: widget.receiptData.description ?? ''
    );
    
    // Log para depuración
    debugPrint('OcrResultScreen inicializada con datos: ${widget.receiptData}');
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2010),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    
    // Verificar que se haya seleccionado una fecha
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una fecha'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
    
    return true;
  }

void _continueToSelectCategory() {
  if (!_validateForm()) {
    return;
  }
  
  // Obtener valores actualizados
  final double amount = double.parse(_amountController.text);
  final String description = _descriptionController.text.trim();
  
  // Crear un objeto ReceiptData actualizado
  final updatedReceiptData = ReceiptData(
    amount: amount,
    date: _selectedDate,
    rawText: widget.receiptData.rawText,
    success: true,
    description: description.isNotEmpty ? description : null,
  );
  
  debugPrint('Continuando a selección de categoría con datos: $updatedReceiptData');
  
  // Navegar a la pantalla de selección de categoría
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CategorySelectionScreen(
        receiptData: updatedReceiptData,
        filePath: widget.filePath,
      ),
    ),
  );
}

// Agregar un método para regresar a la pantalla anterior
void _goBack() {
  debugPrint('Regresando a la pantalla de vista previa del PDF desde OcrResultScreen');
  // Aquí simplemente usamos Navigator.pop, que volverá a la pantalla anterior
  Navigator.pop(context);
}
  
  @override
  Widget build(BuildContext context) {
    // Obtener el factor de escala de texto para adaptabilidad
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final bool isLargeText = textScaleFactor > 1.3;
    
    debugPrint('Factor de escala de texto: $textScaleFactor, isLargeText: $isLargeText');
    
    return Scaffold(
      resizeToAvoidBottomInset: true, // Cambiado a true para que funcione bien con teclado
      appBar: AppBar(
        title: const Text('Resultados del escaneo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: DecorativeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingL),
            child: Form(
              key: _formKey,
              // Usar SingleChildScrollView para manejar cuando aparece el teclado
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: AppDimens.paddingL),
                    _buildFormFields(isLargeText),
                    // Añadimos espacio para no quedar detrás del botón cuando aparece el teclado
                    SizedBox(height: isLargeText ? 120 : 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // Botones fijos en la parte inferior
      bottomNavigationBar: _buildButtons(),
    );
  }
  
  Widget _buildInfoCard() {
    return Card(
      elevation: AppDimens.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información extraída',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: AppDimens.paddingM),
            Text(
              widget.receiptData.success 
                ? 'Hemos detectado la siguiente información en tu recibo. '
                  'Por favor, verifica y corrige si es necesario.'
                : 'No pudimos detectar toda la información. '
                  'Por favor, ingresa los datos manualmente.',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFormFields(bool isLargeText) {
    // Ajustar espacio vertical según el tamaño de texto
    final double verticalSpacing = isLargeText 
        ? AppDimens.paddingM
        : AppDimens.paddingL;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Campo de monto
        Text('Monto', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppDimens.paddingS),
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            prefixText: '\$',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingL,
              vertical: AppDimens.paddingM,
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un monto';
            }
            
            try {
              final amount = double.parse(value);
              if (amount <= 0) {
                return 'El monto debe ser mayor a 0';
              }
            } catch (e) {
              return 'Ingresa un monto válido';
            }
            
            return null;
          },
        ),
        
        SizedBox(height: verticalSpacing),
        
        // Campo de fecha
        Text('Fecha', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppDimens.paddingS),
        TextFormField(
          controller: _dateController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingL,
              vertical: AppDimens.paddingM,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today, color: AppColors.primary),
              onPressed: () => _selectDate(context),
            ),
          ),
          readOnly: true,
          onTap: () => _selectDate(context),
        ),
        
        SizedBox(height: verticalSpacing),
        
        // NUEVO CAMPO: Descripción
        Text(
          'Descripción (opcional)', 
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: AppDimens.paddingS),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Añade una descripción para este recibo',
            hintStyle: AppTextStyles.bodySmall,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingL,
              vertical: AppDimens.paddingM,
            ),
          ),
          // Permitir múltiples líneas para descripciones
          maxLines: isLargeText ? 2 : 3,
          // Configurar tipo de teclado para texto normal
          keyboardType: TextInputType.text,
          // Configurar apariencia de texto más pequeña
          style: AppTextStyles.body.copyWith(
            fontSize: isLargeText ? AppDimens.fontS : AppDimens.fontM,
          ),
          // La descripción es opcional, no necesita validación
        ),
      ],
    );
  }
  

// Y modificar _buildButtons para usar este método
Widget _buildButtons() {
  return Container(
    padding: const EdgeInsets.all(AppDimens.paddingL),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Botón Cancelar
        Expanded(
          child: ElevatedButton(
            onPressed: _goBack, // Usamos el nuevo método
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingL),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                side: const BorderSide(color: AppColors.error),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: AppDimens.paddingL),

        // Botón Continuar
        Expanded(
          child: ElevatedButton(
            onPressed: _continueToSelectCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingL),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
            ),
            child: const Text('Continuar'),
          ),
        ),
      ],
    ),
  );
}
}