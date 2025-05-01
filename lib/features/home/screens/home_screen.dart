// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digirecibos/features/categories/screens/category_files_screen.dart';
import 'package:digirecibos/features/categories/widgets/create_category_dialog.dart';
import 'dart:io';
// Importar los componentes
import 'package:digirecibos/shared/widgets/decorative_background.dart';
import 'package:digirecibos/shared/widgets/app_bottom_navigation.dart';
import 'package:digirecibos/shared/widgets/user_header.dart';
import 'package:digirecibos/features/categories/widgets/category_button.dart';
import 'package:digirecibos/features/categories/widgets/add_category_button.dart';
// Importar constantes
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_strings.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
// Importar el CategoryManager
import 'package:digirecibos/data/services/category_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = AppStrings.defaultUsername;
  bool isLoading = true;
  bool isLoadingCategories = true;
  List<Map<String, dynamic>> categories = [];
  File? _capturedImage;
  File? _selectedPdf;

  // Instancia del CategoryManager
  final CategoryManager _categoryManager = CategoryManager();

  @override
  void initState() {
    super.initState();
    _getUsernameFromFirestore();
    _loadCategories();
  }

  Future<void> _getUsernameFromFirestore() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      try {
        // Intenta obtener el nombre de usuario desde Firestore
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data() as Map<String, dynamic>;
          if (userData.containsKey('username')) {
            setState(() {
              username = userData['username'];
              isLoading = false;
            });
            return;
          }
        }

        // Si no se encuentra en Firestore, usa el email como respaldo
        setState(() {
          username = user.email?.split('@')[0] ?? AppStrings.defaultUsername;
          isLoading = false;
        });
      } catch (e) {
        print('Error obteniendo el nombre de usuario: $e');
        setState(() {
          username = user.email?.split('@')[0] ?? AppStrings.defaultUsername;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoadingCategories = true;
    });

    try {
      // Usar el CategoryManager para cargar las categorías
      final loadedCategories = await _categoryManager.loadCategories();

      if (mounted) {
        setState(() {
          categories = loadedCategories;
          isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('Error cargando categorías: $e');
      if (mounted) {
        setState(() {
          isLoadingCategories = false;
        });
      }
    }
  }

  void _showCreateCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateCategoryDialog(
        onCategoryCreated: (Map<String, dynamic> newCategory) async {
          try {
            // Usar el CategoryManager para crear la categoría
            final category = await _categoryManager.createCategory(newCategory);

            // Recargar todas las categorías para evitar duplicados
            _loadCategories();

            // Mostrar confirmación
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.folderCreatedSuccess)),
            );
          } catch (e) {
            print('Error creando categoría: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(e.toString().contains('iniciar sesión')
                      ? AppStrings.loginRequiredError
                      : AppStrings.folderCreateError)),
            );
          }
        },
      ),
    );
  }

  // Método para eliminar una categoría
  Future<void> _deleteCategory(String categoryId, BuildContext context) async {
    try {
      // Diálogo de confirmación
      bool confirmDelete = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(AppStrings.deleteFolderTitle),
              content: const Text(AppStrings.deleteFolderConfirmation),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(AppStrings.cancelAction),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    AppStrings.deleteAction,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirmDelete) return;

      // Usar el CategoryManager para eliminar la categoría
      await _categoryManager.deleteCategory(categoryId);

      // Recargar las categorías después de eliminar
      _loadCategories();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.folderDeletedSuccess)),
      );
    } catch (e) {
      print('Error eliminando categoría: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString().contains('predeterminadas')
                ? AppStrings.defaultCategoryDeleteError
                : AppStrings.folderDeleteError)),
      );
    }
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

  // Función para manejar la imagen capturada o archivo seleccionado
  void _handleCapturedImage(File? file) {
    if (file != null) {
      final String extension = file.path.split('.').last.toLowerCase();

      if (extension == 'pdf') {
        // Manejar archivo PDF
        setState(() {
          _selectedPdf = file;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.pdfSelectedSuccess),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Manejar imagen
        setState(() {
          _capturedImage = file;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.imageSelectedSuccess),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Función específica para manejar PDFs seleccionados
  void _handleSelectedPdf(File? pdfFile) {
    if (pdfFile != null) {
      setState(() {
        _selectedPdf = pdfFile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.pdfSelectedSuccess),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        child: DecorativeBackground(
          child: Column(
            children: [
              // UserHeader que ahora usa todo el ancho y llega al borde superior
              UserHeader(
                username: username,
                isLoading: isLoading,
              ),

              // Lista de categorías en un scrollable
              Expanded(
                child: isLoadingCategories
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.08,
                        ),
                        child: ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                            ...categories.map((category) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppDimens.paddingL),
                                  child: CategoryButton(
                                    emoji: category['emoji'] as String,
                                    label: category['name'] as String,
                                    color: category['color'] as Color,
                                    id: category['id'] as String,
                                    isDefault: category['isDefault'] as bool,
                                    categoryIcon: _getIconForEmoji(
                                        category['emoji'] as String),
                                    onTap: () {
                                      // Navigate to the category files screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CategoryFilesScreen(
                                            category:
                                                category['name'] as String,
                                            categoryColor:
                                                category['color'] as Color,
                                            categoryIcon: _getIconForEmoji(
                                                category['emoji'] as String),
                                          ),
                                        ),
                                      ).then((_) {
                                        // Recargar las categorías al volver
                                        _loadCategories();
                                      });
                                    },
                                    onDelete: !category['isDefault'] as bool
                                        ? () => _deleteCategory(
                                            category['id'] as String, context)
                                        : null,
                                  ),
                                )),
                            // Add button para crear categorías
                            AddCategoryButton(
                              onTap: _showCreateCategoryDialog,
                            ),
                            // Espacio adicional para evitar que el contenido quede bajo la barra de navegación
                            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                          ],
                        ),
                      ),
              ),

              // Bottom navigation bar
              AppBottomNavigation(currentIndex: 0),
            ],
          ),
        ),
      ),
    );
  }
}