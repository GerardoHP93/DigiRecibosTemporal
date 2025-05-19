class AppStrings {
  // Mensajes comunes
  static const String appName = 'DigiRecibos';
  
  // Categorías predeterminadas
  static const String categoryNameCFE = 'Archivos CFE';
  static const String categoryNameAgua = 'Archivos Agua';
  static const String categoryNameGasolina = 'Archivos Gasolina';
  
  // Mensajes de éxito
  static const String folderCreatedSuccess = 'Carpeta creada correctamente';
  static const String folderDeletedSuccess = 'Carpeta eliminada correctamente';
  static const String pdfSelectedSuccess = 'PDF seleccionado correctamente';
  static const String imageSelectedSuccess = 'Imagen capturada correctamente';
  
  // Mensajes de error
  static const String loginRequiredError = 'Debes iniciar sesión para crear carpetas';
  static const String folderCreateError = 'Error al crear la carpeta';
  static const String folderDeleteError = 'Error al eliminar la carpeta';
  static const String defaultCategoryDeleteError = 'No puedes eliminar las carpetas predeterminadas';
  static const String emptyFolderNameError = 'Por favor ingresa un nombre para la categoría';
  
  // Diálogos
  static const String createFolderTitle = 'Crear Nueva Carpeta';
  static const String folderNameHint = 'Nombre de la carpeta';
  static const String createFolderAction = 'Crear carpeta';
  static const String cancelAction = 'Cancelar';
  static const String deleteAction = 'Eliminar';
  static const String deleteFolderTitle = 'Eliminar carpeta';
  static const String deleteFolderConfirmation = '¿Estás seguro de que deseas eliminar esta carpeta?';
  
  // Categorías y archivos
  static const String emptyCategory = 'No hay archivos en esta categoría';
  static const String viewCharts = 'Ver\ngráficas\nde costos';
  
  // Pantalla de escaneo
  static const String scanReceipt = 'Escanear un recibo';
  static const String takePhoto = 'Tomar foto';
  static const String uploadFromGallery = 'Cargar foto desde el teléfono';
  static const String selectPDF = 'Seleccionar archivo pdf';
  static const String defaultUsername = 'Usuario';
  static const String greeting = '¡Hola';

  // texto de exportación
  static const String exportReport = 'Exportar\nreporte';
  static const String noReceiptsToExport = 'No hay recibos para exportar';
  static const String exportSuccess = 'Reporte generado correctamente';
  static const String exportError = 'Error al exportar reporte';
}