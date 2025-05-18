// lib/features/scan/widgets/pdf_preview_widget.dart

import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart'; // Importamos widgets adicionales
import 'dart:io';
import 'dart:async';

class PdfPreviewWidget extends StatefulWidget {
  final File pdfFile;
  final Function(File, List<int>) onPagesSelected;
  final VoidCallback onCancel;

  const PdfPreviewWidget({
    Key? key,
    required this.pdfFile,
    required this.onPagesSelected,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
}

class _PdfPreviewWidgetState extends State<PdfPreviewWidget> with AutomaticKeepAliveClientMixin {
  PdfDocument? _document;
  int _pageCount = 0;
  int _currentPage = 0;
  bool _isLoading = true;
  bool _isProcessing = false;
  final Set<int> _selectedPages = {};
  final PageController _pageController = PageController();

  // Override del getter keepAlive para AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
    debugPrint('PdfPreviewWidget initState - cargando PDF');
  }

  @override
  void dispose() {
    _document?.dispose();
    _pageController.dispose();
    debugPrint('PdfPreviewWidget dispose - limpiando recursos');
    super.dispose();
  }

  // Método importante: se llama cuando el widget se reconstruye
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Si estamos en estado de procesamiento, volver a estado normal
    // Esto sucederá cuando regresemos desde otra pantalla
    Future.microtask(() {
      if (_isProcessing && mounted) {
        debugPrint('didChangeDependencies - restableciendo _isProcessing desde true a false');
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final document = await PdfDocument.openFile(widget.pdfFile.path);
      
      if (mounted) {
        setState(() {
          _document = document;
          _pageCount = document.pageCount;
          _isLoading = false;
          _isProcessing = false; // Asegurar que siempre comience en false

          // Si solo hay una página, seleccionarla automáticamente
          if (_pageCount == 1) {
            _selectedPages.add(0);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isProcessing = false; // Asegurar que siempre comience en false
        });
        debugPrint('Error al cargar el PDF: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el PDF: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _togglePageSelection(int pageIndex) {
    if (_isProcessing) return; // No permitir interacción durante el procesamiento
    
    setState(() {
      if (_selectedPages.contains(pageIndex)) {
        _selectedPages.remove(pageIndex);
      } else {
        _selectedPages.add(pageIndex);
      }
    });
  }

  void _selectAllPages() {
    if (_isProcessing) return; // No permitir interacción durante el procesamiento
    
    setState(() {
      _selectedPages.clear();
      for (int i = 0; i < _pageCount; i++) {
        _selectedPages.add(i);
      }
    });
  }

  void _clearSelection() {
    if (_isProcessing) return; // No permitir interacción durante el procesamiento
    
    setState(() {
      _selectedPages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin
    
    // Comprobación adicional para resetear el estado de procesamiento
    // cuando el widget se reconstruye (esto sucederá al volver a la pantalla)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isProcessing && mounted && ModalRoute.of(context)?.isCurrent == true) {
        debugPrint('PostFrameCallback detectó que estamos en pantalla activa y _isProcessing=true, reiniciando a false');
        setState(() {
          _isProcessing = false;
        });
      }
    });

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E555C)),
      );
    }

    if (_document == null || _pageCount == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('No se pudo cargar el PDF'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E555C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            // Información del PDF y controles
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1E555C),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'PDF con $_pageCount ${_pageCount == 1 ? 'página' : 'páginas'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Página ${_currentPage + 1} de $_pageCount',
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (_pageCount > 1) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Selecciona las páginas para procesar:',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${_selectedPages.length} ${_selectedPages.length == 1 ? 'página seleccionada' : 'páginas seleccionadas'}',
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: _isProcessing ? null : _selectAllPages,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                foregroundColor: Colors.white,
                                disabledForegroundColor: Colors.white.withOpacity(0.5),
                              ),
                              child: const Text('Todas'),
                            ),
                            TextButton(
                              onPressed: _isProcessing ? null : _clearSelection,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                foregroundColor: Colors.white,
                                disabledForegroundColor: Colors.white.withOpacity(0.5),
                              ),
                              child: const Text('Borrar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Vista previa de las páginas usando PageView con PdfPageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: _isProcessing ? const NeverScrollableScrollPhysics() : null,
                itemCount: _pageCount,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: _isProcessing ? null : () => _togglePageSelection(index),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Usamos los widgets proporcionados por pdf_render para renderizar la página
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: PdfPageView(
                            pdfDocument: _document!,
                            pageNumber: index + 1,
                          ),
                        ),

                        // Indicador de selección
                        if (_selectedPages.contains(index))
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF1E555C),
                                width: 4,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E555C),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // Controles de navegación para PDFs multipágina
        if (_pageCount > 1 && !_isProcessing)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón página anterior
                if (_currentPage > 0)
                  GestureDetector(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 40,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8),
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),

                // Botón página siguiente
                if (_currentPage < _pageCount - 1)
                  GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // Barra inferior con botones
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing 
                      ? null 
                      : () {
                          debugPrint('Botón Cancelar presionado');
                          widget.onCancel();
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing || _selectedPages.isEmpty
                        ? null
                        : () {
                            debugPrint('Botón Continuar presionado - activando _isProcessing');
                            setState(() {
                              _isProcessing = true;
                            });
                            
                            // IMPORTANTE: Procesamos las páginas seleccionadas
                            widget.onPagesSelected(
                              widget.pdfFile,
                              _selectedPages.toList(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E555C),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Continuar'),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Overlay cuando está procesando
        if (_isProcessing)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Procesando PDF...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}