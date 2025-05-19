// lib/features/categories/screens/category_files_screen.dart
import 'package:digirecibos/features/categories/widgets/filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Importante para manejar StreamSubscription
import 'package:digirecibos/features/export/widgets/export_report_button.dart';


// Importar componentes reutilizables
import 'package:digirecibos/shared/widgets/decorative_background.dart';
import 'package:digirecibos/shared/widgets/app_bottom_navigation.dart';
import 'package:digirecibos/features/categories/widgets/file_item.dart';
import 'package:digirecibos/features/categories/widgets/empty_category_message.dart';
import 'package:digirecibos/features/categories/widgets/category_header.dart';
import 'package:digirecibos/features/analytics/widgets/view_charts_button.dart';
import 'package:digirecibos/features/categories/screens/receipt_detail_screen.dart';

// Importar modelos y servicios
import 'package:digirecibos/data/models/receipt.dart';
import 'package:digirecibos/data/repositories/receipt_repository.dart';
import 'package:digirecibos/data/services/category_manager.dart';
import 'package:digirecibos/features/analytics/services/chart_data_service.dart';

// Importar constantes
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_strings.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';

class CategoryFilesScreen extends StatefulWidget {
  final String category;
  final Color categoryColor; // Seguirá recibiendo este parámetro pero internamente usaremos AppColors.primary
  final IconData categoryIcon;
  
  const CategoryFilesScreen({
    Key? key,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  State<CategoryFilesScreen> createState() => _CategoryFilesScreenState();
}

class _CategoryFilesScreenState extends State<CategoryFilesScreen> {
  final CategoryManager _categoryManager = CategoryManager();
  final ReceiptRepository _receiptRepository = ReceiptRepository();
  final ChartDataService _chartDataService = ChartDataService();
 
  List<Receipt> _receipts = [];
  List<Receipt>? _allReceipts; // Lista de todos los recibos sin filtrar
  String? _categoryId;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  // Filtros
  String _sortOption = 'date_desc'; // Opciones: date_asc, date_desc, amount_asc, amount_desc
  int? _filterYear;
  int? _filterMonthStart;
  int? _filterMonthEnd;

  // Lista de años disponibles en los recibos
  final List<int> _availableYears = [];

  // StreamSubscription para cancelar la suscripción cuando se destruye el widget
  StreamSubscription? _receiptsSubscription;

  @override
  void initState() {
    super.initState();
    _loadCategoryId();
  }

  @override
  void dispose() {
    // Cancelar la suscripción para evitar memory leaks y duplicados
    _receiptsSubscription?.cancel();
    super.dispose();
  }

  // Encontrar el ID de la categoría basado en su nombre
  Future<void> _loadCategoryId() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Cargar categorías
      final categories = await _categoryManager.loadCategories();
      
      // Buscar categoría por nombre
      final categoryMatch = categories.firstWhere(
        (category) => category['name'] == widget.category,
        orElse: () => {},
      );

      if (categoryMatch.isNotEmpty) {
        // Obtener el ID de la categoría
        _categoryId = categoryMatch['id'] as String;
        // Iniciar escucha de recibos
        _startListeningReceipts();
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'No se encontró la categoría';
        });
      }
    } catch (e) {
      debugPrint('Error al cargar ID de categoría: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error al cargar la categoría';
      });
    }
  }

  // Iniciar escucha de cambios en los recibos
  void _startListeningReceipts() {
    if (_categoryId == null) return;
    
    try {
      // Cancelar cualquier suscripción anterior para evitar duplicados
      _receiptsSubscription?.cancel();
      
      // Obtener el stream de recibos
      final stream = _receiptRepository.getReceiptsByCategory(_categoryId!);
      
      // Suscribirse a los cambios
      _receiptsSubscription = stream.listen(
        (receivedReceipts) {
          setState(() {
            _allReceipts = receivedReceipts; // Guardar la lista completa
            
            // Extraer los años disponibles de los recibos
            _extractAvailableYears(receivedReceipts);
            
            // Aplicar filtros con la nueva lista de recibos
            _receipts = _applyFilters(receivedReceipts);
            _isLoading = false;
          });
        },
        onError: (error) {
          debugPrint('Error al escuchar recibos: $error');
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Error al cargar los recibos';
          });
        }
      );
    } catch (e) {
      debugPrint('Error al iniciar escucha de recibos: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error al cargar los recibos';
      });
    }
  }
  
  // Extraer los años disponibles de los recibos
  void _extractAvailableYears(List<Receipt> receipts) {
    // Limpiar la lista actual
    _availableYears.clear();
    
    try {
      // Usar el servicio de datos de gráficas para obtener los años disponibles
      final years = _chartDataService.getAvailableYears(receipts);
      
      // Actualizar la lista con los años que tienen recibos
      _availableYears.addAll(years);
      
      debugPrint('Años extraídos de los recibos: $_availableYears');
      
      // Verificar si el año actual de filtro existe en los años disponibles
      if (_filterYear != null && !_availableYears.contains(_filterYear)) {
        debugPrint('El año de filtro $_filterYear ya no está disponible en los recibos');
        // Resetear el filtro de año si ya no está disponible
        _filterYear = null;
        _filterMonthStart = null;
        _filterMonthEnd = null;
      }
    } catch (e) {
      debugPrint('Error al extraer años disponibles: $e');
      // En caso de error, no modificamos los años disponibles
    }
  }

  // Aplicar filtros a la lista de recibos
  List<Receipt> _applyFilters(List<Receipt> receipts) {
    debugPrint('Aplicando filtros - Año: $_filterYear, Meses: $_filterMonthStart a $_filterMonthEnd, Orden: $_sortOption');
    debugPrint('Cantidad de recibos antes de filtrar: ${receipts.length}');
   
    List<Receipt> filteredReceipts = List.from(receipts);
    
    // Aplicar filtro por año
    if (_filterYear != null) {
      filteredReceipts = filteredReceipts
          .where((receipt) => receipt.date.year == _filterYear)
          .toList();
     
      debugPrint('Después de filtrar por año $_filterYear: ${filteredReceipts.length} recibos');
    }

    // Aplicar filtro por rango de meses
    if (_filterYear != null && _filterMonthStart != null && _filterMonthEnd != null) {
      filteredReceipts = filteredReceipts
          .where((receipt) => 
              receipt.date.month >= _filterMonthStart! &&
              receipt.date.month <= _filterMonthEnd!)
          .toList();
     
      debugPrint('Después de filtrar por meses $_filterMonthStart-$_filterMonthEnd: ${filteredReceipts.length} recibos');
    }

    // Aplicar ordenamiento
    filteredReceipts.sort((a, b) {
      switch (_sortOption) {
        case 'date_asc':
          return a.date.compareTo(b.date);
        case 'date_desc':
          return b.date.compareTo(a.date);
        case 'amount_asc':
          return a.amount.compareTo(b.amount);
        case 'amount_desc':
          return b.amount.compareTo(a.amount);
        default:
          return b.date.compareTo(a.date);
      }
    });

    debugPrint('Cantidad de recibos después de filtrar: ${filteredReceipts.length}');
    return filteredReceipts;
  }

  // Mostrar diálogo de filtros
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        currentYear: _filterYear,
        currentMonthStart: _filterMonthStart,
        currentMonthEnd: _filterMonthEnd,
        currentSortOption: _sortOption,
        availableYears: _availableYears,
        onApply: (year, monthStart, monthEnd, sortOption) {
          setState(() {
            // Registrar los cambios en los filtros
            debugPrint('Filtros cambiados - Año: $year, Meses: $monthStart a $monthEnd, Orden: $sortOption');
           
            _filterYear = year;
            _filterMonthStart = monthStart;
            _filterMonthEnd = monthEnd;
            _sortOption = sortOption;
           
            // Aplicar filtros usando la lista completa original
            if (_allReceipts != null) {
              _receipts = _applyFilters(_allReceipts!);
            }
          });
        },
      ),
    );
  }

  // Navegar a la pantalla de detalle al tocar un recibo
  void _navigateToReceiptDetail(Receipt receipt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptDetailScreen(
          receipt: receipt,
          categoryColor: AppColors.primary,
        ),
      ),
    );
  }

// lib/features/categories/screens/category_files_screen.dart
    // En el método build, reemplaza la estructura existente con:

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        resizeToAvoidBottomInset: false, // Evita que el contenido se desplace cuando aparece el teclado
        body: DecorativeBackground(
          child: Column(
            children: [
              // Header with back button and category name (ahora con padding integrado)
              CategoryHeader(
                categoryName: widget.category,
                categoryColor: widget.categoryColor,
                categoryIcon: widget.categoryIcon,
                onBackPress: () {
                  Navigator.pop(context);
                },
                onFilterPress: _showFilterDialog,
              ),
              
              // List of files
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _hasError
                        ? _buildErrorMessage()
                        : _receipts.isEmpty
                            ? const EmptyCategoryMessage()
                            : _buildReceiptsList(),
              ),
              
              // "Ver gráficas de costos" button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón para exportar el reporte
                  ExportReportButton(
                    categoryId: _categoryId ?? '',
                    categoryName: widget.category,
                    receipts: _receipts,
                  ),
                  
                  // Botón para ver gráficas de costos
                  ViewChartsButton(
                    categoryId: _categoryId ?? '',
                    categoryName: widget.category,
                    categoryColor: widget.categoryColor,
                    categoryIcon: widget.categoryIcon,
                  ),
                ],
              ),
              
              // Bottom navigation bar with consistent navigation
              AppBottomNavigation(
                currentIndex: 0, // Considerar actualizar según la página actual
              ),
            ],
          ),
        ),
      );
    }

  Widget _buildErrorMessage() {
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
              _errorMessage ?? 'Ocurrió un error al cargar los archivos',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.paddingL),
            ElevatedButton(
              onPressed: _loadCategoryId,
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

  // CAMBIO: Reemplazamos la cuadrícula por una lista
  Widget _buildReceiptsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingL,
        vertical: AppDimens.paddingM,
      ),
      child: ListView.builder(
        itemCount: _receipts.length,
        itemBuilder: (context, index) {
          return FileItem(
            receipt: _receipts[index],
            categoryColor: AppColors.primary,
            onTap: () => _navigateToReceiptDetail(_receipts[index]),
          );
        },
      ),
    );
  }
}