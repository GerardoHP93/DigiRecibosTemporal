// lib/features/analytics/screens/charts_screen.dart
import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_strings.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/data/models/receipt.dart';
import 'package:digirecibos/data/repositories/receipt_repository.dart';
import 'package:digirecibos/features/analytics/services/chart_data_service.dart';
import 'package:digirecibos/features/analytics/widgets/charts_filter_dialog.dart';
import 'package:digirecibos/features/analytics/widgets/expense_chart.dart';
import 'package:digirecibos/shared/widgets/app_bottom_navigation.dart';
import 'package:digirecibos/shared/widgets/decorative_background.dart';
import 'package:digirecibos/shared/widgets/app_header.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importar para inicializar datos locales

class ChartsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const ChartsScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  final ReceiptRepository _receiptRepository = ReceiptRepository();
  final ChartDataService _chartDataService = ChartDataService();
  
  List<Receipt> _receipts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  
  // Filtros
  int? _selectedYear;
  int? _selectedMonthStart;
  int? _selectedMonthEnd;
  List<int> _availableYears = [];
  
  // Datos procesados para la gráfica
  Map<String, double> _chartData = {};
  double _totalAmount = 0;
  double _maxAmount = 0;
  
  // Flag para indicar si los datos de localización han sido inicializados
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _loadReceipts();
  }
  
  // Inicializar datos de localización para formato de fechas
  Future<void> _initializeLocale() async {
    try {
      // Inicializar datos de localización para español
      await initializeDateFormatting('es', null);
      setState(() {
        _localeInitialized = true;
      });
      debugPrint('Datos de localización inicializados correctamente');
    } catch (e) {
      debugPrint('Error al inicializar datos de localización: $e');
      // Si hay error, seguimos con el código, pero pueden ocurrir errores de formato
    }
  }

  Future<void> _loadReceipts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    
    try {
      debugPrint('Cargando recibos para la categoría: ${widget.categoryId}');
      
      // Suscribirse al stream de recibos
      final receiptsStream = _receiptRepository.getReceiptsByCategory(widget.categoryId);
      
      receiptsStream.listen(
        (receipts) {
          setState(() {
            _receipts = receipts;
            _isLoading = false;
            
            // Obtener años disponibles
            _availableYears = _chartDataService.getAvailableYears(receipts);
            
            // Seleccionar el año con más recibos por defecto si no hay año seleccionado
            if (_selectedYear == null && _availableYears.isNotEmpty) {
              _selectedYear = _chartDataService.getMostFrequentYear(receipts);
            }
            
            // Procesar datos para la gráfica
            _processChartData();
          });
        },
        onError: (error) {
          debugPrint('Error al obtener recibos: $error');
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Error al cargar los recibos';
          });
        }
      );
    } catch (e) {
      debugPrint('Error al cargar recibos: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error al cargar los recibos';
      });
    }
  }
  
  // Procesar los datos para la gráfica
  void _processChartData() {
    try {
      // Procesar datos para el gráfico
      _chartData = _chartDataService.processReceiptsByMonth(
        receipts: _receipts,
        year: _selectedYear,
        startMonth: _selectedMonthStart,
        endMonth: _selectedMonthEnd,
      );
      
      // Calcular suma total
      _totalAmount = _chartDataService.calculateTotalAmount(
        receipts: _receipts,
        year: _selectedYear,
        startMonth: _selectedMonthStart,
        endMonth: _selectedMonthEnd,
      );
      
      // Encontrar el valor máximo para escalar el gráfico
      _maxAmount = 0;
      _chartData.forEach((_, value) {
        if (value > _maxAmount) {
          _maxAmount = value;
        }
      });
      
      // Ajustar el valor máximo para mejor visualización
      if (_maxAmount == 0) {
        _maxAmount = 100;
      } else {
        // Usar un algoritmo más granular para determinar la escala
        _maxAmount = _calculateOptimalMaxY(_maxAmount);
      }
      
      debugPrint('Datos procesados: $_chartData');
      debugPrint('Total: $_totalAmount, Máximo: $_maxAmount');
    } catch (e) {
      debugPrint('Error al procesar datos para gráfica: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Error al procesar datos para la gráfica';
      });
    }
  }

  // Calcula un valor máximo óptimo para el eje Y
  double _calculateOptimalMaxY(double rawMax) {
    debugPrint('Calculando maxY óptimo para valor: $rawMax');
    
    // Para valores pequeños, usar intervalos más pequeños
    if (rawMax < 100) {
      return (rawMax / 20).ceil() * 20.0;
    }
    
    // Para valores moderados
    if (rawMax < 500) {
      return (rawMax / 50).ceil() * 50.0;
    }
    
    // Para valores medianos
    if (rawMax < 1000) {
      return (rawMax / 100).ceil() * 100.0;
    }
    
    // Para valores grandes
    if (rawMax < 5000) {
      return (rawMax / 500).ceil() * 500.0;
    }
    
    // Para valores muy grandes
    return (rawMax / 1000).ceil() * 1000.0;
  }
  
  // Mostrar diálogo de filtros
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => ChartsFilterDialog(
        currentYear: _selectedYear,
        currentMonthStart: _selectedMonthStart,
        currentMonthEnd: _selectedMonthEnd,
        availableYears: _availableYears,
        onApply: (year, monthStart, monthEnd) {
          setState(() {
            debugPrint('Filtros aplicados - Año: $year, MesInicio: $monthStart, MesFin: $monthEnd');
            _selectedYear = year;
            _selectedMonthStart = monthStart;
            _selectedMonthEnd = monthEnd;
            
            // Reprocesar datos con los nuevos filtros
            _processChartData();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Formatear el monto total
    final formattedAmount = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      locale: 'es_MX',
    ).format(_totalAmount);
    
    return Scaffold(
      body: DecorativeBackground(
        child: Column(
          children: [
            // Usar el nuevo header unificado
            AppHeader(
              title: 'Gráfica: ${widget.categoryName}',
              onBackPress: () => Navigator.pop(context),
              actions: [
                // Icono de filtro
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
            
            // Contenido principal
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                  ? _buildErrorMessage()
                  : _receipts.isEmpty
                    ? _buildEmptyMessage()
                    : _buildChartContent(formattedAmount),
            ),
            
            // Bottom navigation bar
            AppBottomNavigation(currentIndex: 0),
          ],
        ),
      ),
    );
  }
  
  // Modificar el método _buildChartContent para añadir más espacio
  Widget _buildChartContent(String formattedAmount) {
    // Medidas de la pantalla para responsividad
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 600;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Añadir más espacio aquí entre el header y el título
          SizedBox(height: isSmallScreen ? AppDimens.paddingL : AppDimens.paddingXL),
          
          // Título de la gráfica con filtros aplicados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
            child: Text(
              _buildChartTitle(),
              style: AppTextStyles.subtitle,
            ),
          ),
          
          // Espacio ajustable según tamaño de pantalla
          SizedBox(height: isSmallScreen ? AppDimens.paddingM : AppDimens.paddingL),
          
          // La gráfica (ahora con mejor aprovechamiento del espacio)
          ExpenseChart(
            monthlyData: _chartData,
            barColor: AppColors.primary,
            maxY: _maxAmount,
          ),
          
          // Espacio ajustable según tamaño de pantalla
          SizedBox(height: isSmallScreen ? AppDimens.paddingS : AppDimens.paddingM),
          
          // Sumatorio total
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.paddingL,
              vertical: isSmallScreen ? AppDimens.paddingS : AppDimens.paddingM,
            ),
            child: Card(
              elevation: AppDimens.elevationM,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusL),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.paddingL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Suma Total:',
                      style: AppTextStyles.subtitle,
                    ),
                    Text(
                      formattedAmount,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: AppDimens.fontXL,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Nota informativa sobre filtros (ajustada para pantallas pequeñas)
          if (!isSmallScreen)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingL,
                vertical: AppDimens.paddingM,
              ),
              child: Text(
                'Puedes filtrar por año y rango de meses usando el botón de filtro en la esquina superior derecha.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          
          // Asegurar espacio al final para evitar que el contenido quede detrás de la barra de navegación
          SizedBox(height: isSmallScreen ? AppDimens.paddingL : AppDimens.paddingXL),
        ],
      ),
    );
  }
  
  // Construye el título de la gráfica basado en los filtros
  String _buildChartTitle() {
    if (_selectedYear == null) {
      return 'Gastos de todos los años';
    }
    
    if (_selectedMonthStart == null || _selectedMonthEnd == null) {
      return 'Gastos del año $_selectedYear';
    }
    
    // Manejo de error para prevenir la excepción de localización
    if (!_localeInitialized) {
      // Fallback a nombres de meses en español sin depender de la localización
      final List<String> meses = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      
      // Si inicio y fin de mes son iguales, mostrar solo un mes
      if (_selectedMonthStart == _selectedMonthEnd) {
        return 'Gastos de ${meses[_selectedMonthStart! - 1]} de $_selectedYear';
      }
      
      // Mostrar rango de meses
      return 'Gastos de ${meses[_selectedMonthStart! - 1]} a ${meses[_selectedMonthEnd! - 1]} de $_selectedYear';
    }
    
    try {
      // Si inicio y fin de mes son iguales, mostrar solo un mes
      if (_selectedMonthStart == _selectedMonthEnd) {
        final monthName = DateFormat('MMMM', 'es').format(DateTime(_selectedYear!, _selectedMonthStart!));
        return 'Gastos de $monthName de $_selectedYear';
      }
      
      // Mostrar rango de meses
      final startMonthName = DateFormat('MMMM', 'es').format(DateTime(_selectedYear!, _selectedMonthStart!));
      final endMonthName = DateFormat('MMMM', 'es').format(DateTime(_selectedYear!, _selectedMonthEnd!));
      return 'Gastos de $startMonthName a $endMonthName de $_selectedYear';
    } catch (e) {
      debugPrint('Error al formatear nombres de meses: $e');
      
      // Fallback a nombres básicos si hay error
      return 'Gastos de mes $_selectedMonthStart a mes $_selectedMonthEnd de $_selectedYear';
    }
  }
  
  // Mensaje cuando no hay recibos
  Widget _buildEmptyMessage() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppDimens.paddingL),
        padding: const EdgeInsets.all(AppDimens.paddingL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.insert_chart_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimens.paddingL),
            Text(
              'No hay recibos en esta categoría',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.paddingM),
            Text(
              'Añade recibos a esta categoría para ver gráficas de gastos',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // Mensaje de error
  Widget _buildErrorMessage() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppDimens.paddingL),
        padding: const EdgeInsets.all(AppDimens.paddingL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: AppDimens.paddingM),
            Text(
              _errorMessage ?? 'Ocurrió un error al cargar los datos',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.paddingL),
            ElevatedButton(
              onPressed: _loadReceipts,
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
}