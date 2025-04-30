// lib/features/categories/widgets/filter_dialog.dart

import 'package:flutter/material.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';

class FilterDialog extends StatefulWidget {
  final int? currentYear;
  final int? currentMonthStart;
  final int? currentMonthEnd;
  final String currentSortOption;
  final List<int> availableYears;
  final Function(int?, int?, int?, String) onApply;

  const FilterDialog({
    Key? key,
    this.currentYear,
    this.currentMonthStart,
    this.currentMonthEnd,
    required this.currentSortOption,
    required this.availableYears,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late int? _selectedYear;
  late int? _selectedMonthStart;
  late int? _selectedMonthEnd;
  late String _selectedSortOption;
 
  final List<Map<String, dynamic>> _sortOptions = [
    {'value': 'date_desc', 'label': 'Más recientes primero'},
    {'value': 'date_asc', 'label': 'Más antiguos primero'},
    {'value': 'amount_desc', 'label': 'Mayor monto primero'},
    {'value': 'amount_asc', 'label': 'Menor monto primero'},
  ];
 
  final List<Map<String, dynamic>> _months = [
    {'value': 1, 'label': 'Enero'},
    {'value': 2, 'label': 'Febrero'},
    {'value': 3, 'label': 'Marzo'},
    {'value': 4, 'label': 'Abril'},
    {'value': 5, 'label': 'Mayo'},
    {'value': 6, 'label': 'Junio'},
    {'value': 7, 'label': 'Julio'},
    {'value': 8, 'label': 'Agosto'},
    {'value': 9, 'label': 'Septiembre'},
    {'value': 10, 'label': 'Octubre'},
    {'value': 11, 'label': 'Noviembre'},
    {'value': 12, 'label': 'Diciembre'},
    {'value': null, 'label': 'Todos los meses'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.currentYear;
    _selectedMonthStart = widget.currentMonthStart;
    _selectedMonthEnd = widget.currentMonthEnd;
    _selectedSortOption = widget.currentSortOption;
   
    // Asegurar que el mes final es posterior al inicial
    if (_selectedMonthStart != null && _selectedMonthEnd != null) {
      if (_selectedMonthStart! > _selectedMonthEnd!) {
        _selectedMonthEnd = _selectedMonthStart;
      }
    }
    
    debugPrint('FilterDialog iniciado - Años disponibles: ${widget.availableYears}');
    debugPrint('FilterDialog iniciado - Valores actuales: Año=$_selectedYear, MesInicio=$_selectedMonthStart, MesFin=$_selectedMonthEnd, Orden=$_selectedSortOption');
  }
 
  void _clearFilters() {
    setState(() {
      _selectedYear = null;
      _selectedMonthStart = null;
      _selectedMonthEnd = null;
      // No restaurar la opción de ordenamiento para mantener la preferencia del usuario
    });
    
    debugPrint('Filtros limpiados: año=null, meses=null');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Construyendo FilterDialog - Año: $_selectedYear, MesInicio: $_selectedMonthStart, MesFin: $_selectedMonthEnd, Orden: $_selectedSortOption');
    
    return AlertDialog(
      title: const Text('Filtros', style: AppTextStyles.dialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtro por año
            const Text('Año', style: AppTextStyles.subtitle),
            const SizedBox(height: AppDimens.paddingS),
            _buildYearDropdown(),
            const SizedBox(height: AppDimens.paddingL),
           
            // Filtro por mes (desde)
            if (_selectedYear != null) ...[
              const Text('Desde mes', style: AppTextStyles.subtitle),
              const SizedBox(height: AppDimens.paddingS),
              _buildMonthStartDropdown(),
              const SizedBox(height: AppDimens.paddingL),
            ],
           
            // Filtro por mes (hasta)
            if (_selectedYear != null && _selectedMonthStart != null) ...[
              const Text('Hasta mes', style: AppTextStyles.subtitle),
              const SizedBox(height: AppDimens.paddingS),
              _buildMonthEndDropdown(),
              const SizedBox(height: AppDimens.paddingL),
            ],
           
            // Ordenar por
            const Text('Ordenar por', style: AppTextStyles.subtitle),
            const SizedBox(height: AppDimens.paddingS),
            _buildSortDropdown(),
           
            // Botón para limpiar filtros
            if (_selectedYear != null || _selectedMonthStart != null || _selectedMonthEnd != null) ...[
              const SizedBox(height: AppDimens.paddingL),
              Center(
                child: TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, color: AppColors.error),
                  label: const Text('Limpiar filtros', style: TextStyle(color: AppColors.error)),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            debugPrint('Diálogo de filtro cancelado');
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            debugPrint('Aplicando filtros: Año=$_selectedYear, MesInicio=$_selectedMonthStart, MesFin=$_selectedMonthEnd, Orden=$_selectedSortOption');
            widget.onApply(
              _selectedYear,
              _selectedMonthStart,
              _selectedMonthEnd,
              _selectedSortOption
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
 
  Widget _buildYearDropdown() {
    // Verificar que haya años disponibles
    if (widget.availableYears.isEmpty) {
      debugPrint('No hay años disponibles para mostrar en el dropdown');
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimens.radiusS),
        ),
        child: DropdownButton<int?>(
          value: null,
          isExpanded: true,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem<int?>(
              value: null,
              child: Text('No hay años disponibles'),
            ),
          ],
          onChanged: null, // Deshabilitado
        ),
      );
    }
    
    // Construir lista de items con los años disponibles
    final items = [
      const DropdownMenuItem<int?>(
        value: null,
        child: Text('Todos los años'),
      ),
      ...widget.availableYears.map((year) => DropdownMenuItem<int?>(
        value: year,
        child: Text(year.toString()),
      )).toList(),
    ];
    
    // Si el año seleccionado no está en la lista de años disponibles, lo reseteamos
    if (_selectedYear != null && !widget.availableYears.contains(_selectedYear)) {
      debugPrint('El año seleccionado $_selectedYear no está en la lista de años disponibles. Reseteando.');
      _selectedYear = null;
    }
   
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
      ),
      child: DropdownButton<int?>(
        value: _selectedYear,
        isExpanded: true,
        underline: const SizedBox(),
        items: items,
        onChanged: (value) {
          setState(() {
            _selectedYear = value;
            // Si se cambia el año, resetear los meses
            if (value == null) {
              _selectedMonthStart = null;
              _selectedMonthEnd = null;
            }
          });
        },
      ),
    );
  }
 
  Widget _buildMonthStartDropdown() {
    final items = _months.map((month) => DropdownMenuItem<int?>(
      value: month['value'] as int?,
      child: Text(month['label'] as String),
    )).toList();
   
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
      ),
      child: DropdownButton<int?>(
        value: _selectedMonthStart,
        isExpanded: true,
        underline: const SizedBox(),
        items: items,
        onChanged: (value) {
          setState(() {
            _selectedMonthStart = value;
            // Si el mes de inicio es mayor que el mes de fin, actualizar el mes de fin
            if (_selectedMonthEnd != null && _selectedMonthStart != null) {
              if (_selectedMonthStart! > _selectedMonthEnd!) {
                _selectedMonthEnd = _selectedMonthStart;
              }
            } else if (_selectedMonthStart != null) {
              // Si se selecciona un mes de inicio, pero no hay mes de fin, establecer el mismo
              _selectedMonthEnd = _selectedMonthStart;
            } else {
              // Si se deselecciona el mes de inicio, también limpiar el mes de fin
              _selectedMonthEnd = null;
            }
          });
        },
      ),
    );
  }
 
  Widget _buildMonthEndDropdown() {
    // Filtrar los meses para que solo se muestren los que son mayores o iguales al mes de inicio
    final filteredMonths = _months.where((month) {
      final monthValue = month['value'] as int?;
      return monthValue == null ||
             _selectedMonthStart == null ||
             monthValue >= _selectedMonthStart!;
    }).toList();
   
    final items = filteredMonths.map((month) => DropdownMenuItem<int?>(
      value: month['value'] as int?,
      child: Text(month['label'] as String),
    )).toList();
   
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
      ),
      child: DropdownButton<int?>(
        value: _selectedMonthEnd,
        isExpanded: true,
        underline: const SizedBox(),
        items: items,
        onChanged: (value) {
          setState(() {
            _selectedMonthEnd = value;
          });
        },
      ),
    );
  }
 
  Widget _buildSortDropdown() {
    final items = _sortOptions.map((option) => DropdownMenuItem<String>(
      value: option['value'] as String,
      child: Text(option['label'] as String),
    )).toList();
   
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
      ),
      child: DropdownButton<String>(
        value: _selectedSortOption,
        isExpanded: true,
        underline: const SizedBox(),
        items: items,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedSortOption = value;
            });
          }
        },
      ),
    );
  }
}