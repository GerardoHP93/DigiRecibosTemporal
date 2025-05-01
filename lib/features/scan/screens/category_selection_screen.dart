// lib/features/scan/screens/category_selection_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_strings.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/data/models/receipt.dart';
import 'package:digirecibos/data/repositories/receipt_repository.dart';
import 'package:digirecibos/data/services/category_manager.dart';
import 'package:digirecibos/features/categories/screens/category_files_screen.dart';
import 'package:digirecibos/features/scan/models/receipt_data.dart';
import 'package:digirecibos/shared/widgets/decorative_background.dart';

class CategorySelectionScreen extends StatefulWidget {
  final ReceiptData receiptData;
  final String filePath;

  const CategorySelectionScreen({
    Key? key,
    required this.receiptData,
    required this.filePath,
  }) : super(key: key);

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final CategoryManager _categoryManager = CategoryManager();
  final ReceiptRepository _receiptRepository = ReceiptRepository();

  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedCategoryId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loadedCategories = await _categoryManager.loadCategories();
      
      if (mounted) {
        setState(() {
          _categories = loadedCategories;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar categorías: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar categorías. Por favor, inténtalo de nuevo.';
        });
      }
    }
  }

  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  IconData _getIconForEmoji(String emoji) {
    // Mapear emojis a iconos de Flutter
    switch (emoji) {
      case '⚡':
        return Icons.bolt;
      case '💧':
        return Icons.water_drop;
      case '⛽':
        return Icons.local_gas_station;
      case '🛒':
        return Icons.shopping_cart;
      case '🏪':
        return Icons.store;
      case '📱':
        return Icons.smartphone;
      case '💻':
        return Icons.laptop;
      case '🚗':
        return Icons.directions_car;
      case '🏠':
        return Icons.home_work;
      case '📄':
        return Icons.description;
      case '💼':
        return Icons.work;
      case '🔋':
        return Icons.battery_charging_full;
      default:
        return Icons.folder;
    }
  }

  Future<void> _saveReceiptToCategory() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una categoría primero'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Encontrar la categoría seleccionada
      final selectedCategory = _categories.firstWhere(
        (category) => category['id'] == _selectedCategoryId,
      );
      
      // Crear archivo File desde la ruta
      final file = File(widget.filePath);
      
      // Subir el recibo a Firebase
      final receipt = await _receiptRepository.uploadReceipt(
        categoryId: _selectedCategoryId!,
        receiptData: widget.receiptData,
        file: file,
      );
      
      // Navegar a la pantalla de archivos de la categoría seleccionada
      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recibo guardado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        
        debugPrint('Navegando a CategoryFilesScreen y manteniendo la ruta inicial');
        
        // Navegar a la pantalla de la categoría manteniendo la ruta inicial
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryFilesScreen(
              category: selectedCategory['name'] as String,
              categoryColor: selectedCategory['color'] as Color,
              categoryIcon: _getIconForEmoji(selectedCategory['emoji'] as String),
            ),
          ),
          (route) => route.isFirst, // Solo mantener la ruta inicial (Home)
        );
      }
    } catch (e) {
      debugPrint('Error al guardar el recibo: $e');
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Error al guardar el recibo. Por favor, inténtalo de nuevo.';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Evita que el contenido se desplace cuando aparece el teclado
      appBar: AppBar(
        title: const Text('Seleccionar categoría'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: DecorativeBackground(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: AppDimens.paddingM),
              Text(
                _errorMessage!,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.paddingL),
              ElevatedButton(
                onPressed: _loadCategories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_isSaving) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppDimens.paddingL),
            Text(
              'Guardando recibo...',
              style: AppTextStyles.body,
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimens.paddingL),
          child: Card(
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
                    'Información del recibo',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppDimens.paddingM),
                  _buildReceiptInfo('Monto:', widget.receiptData.formattedAmount ?? 'No disponible'),
                  _buildReceiptInfo('Fecha:', widget.receiptData.formattedDate ?? 'No disponible'),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
          child: Text(
            '¿Dónde quieres guardar este recibo?',
            style: AppTextStyles.subtitle,
          ),
        ),
        const SizedBox(height: AppDimens.paddingM),
        Expanded(
          child: _categories.isEmpty
            ? const Center(
                child: Text('No hay categorías disponibles'),
              )
            : _buildCategoriesList(),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimens.paddingL),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveReceiptToCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingL),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
              ),
              child: const Text('Guardar recibo'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingXS),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: AppDimens.paddingM),
          Text(
            value,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final bool isSelected = category['id'] == _selectedCategoryId;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.paddingM),
          child: InkWell(
            onTap: _isSaving ? null : () => _selectCategory(category['id'] as String),
            borderRadius: BorderRadius.circular(AppDimens.radiusCircular),
            child: Container(
              height: AppDimens.categoryButtonHeight,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppDimens.radiusCircular),
                border: Border.all(
                  color: isSelected ? AppColors.primary : category['color'] as Color,
                  width: AppDimens.borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: AppDimens.elevationS,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppDimens.paddingL),
                  Text(
                    category['emoji'] as String,
                    style: const TextStyle(fontSize: AppDimens.fontXXL),
                  ),
                  const SizedBox(width: AppDimens.paddingM),
                  Expanded(
                    child: Text(
                      category['name'] as String,
                      style: AppTextStyles.categoryName,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(right: AppDimens.paddingL),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: AppDimens.iconS,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}