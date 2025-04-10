import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_strings.dart';

// Clase singleton para gestionar el estado de las categorías
class CategoryManager {
  static final CategoryManager _instance = CategoryManager._internal();

  factory CategoryManager() {
    return _instance;
  }

  CategoryManager._internal();

  List<Map<String, dynamic>> categories = [];
  bool hasLoadedCategories = false;

  // Key para almacenar categorías en SharedPreferences
  static const String _localCategoriesKey = 'local_categories';

  // Lista de categorías por defecto
  final List<Map<String, dynamic>> defaultCategories = [
    {
      'id': 'cfe',
      'name': AppStrings.categoryNameCFE,
      'emoji': '⚡',
      'color': AppColors.categoryGreen,
      'isDefault': true,
    },
    {
      'id': 'agua',
      'name': AppStrings.categoryNameAgua,
      'emoji': '💧',
      'color': AppColors.categoryBlue,
      'isDefault': true,
    },
    {
      'id': 'gasolina',
      'name': AppStrings.categoryNameGasolina,
      'emoji': '⛽',
      'color': AppColors.categoryRed,
      'isDefault': true,
    },
  ];

  // Método para agregar una categoría personalizada y sincronizarla con Firebase y local
  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> newCategory) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para crear carpetas');
    }

    // Guardar en Firestore
    final docRef = await FirebaseFirestore.instance
        .collection('categories')
        .add({
      'userId': user.uid,
      'name': newCategory['name'],
      'emoji': newCategory['emoji'],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Crear objeto de categoría completo
    final category = {
      'id': docRef.id,
      'name': newCategory['name'],
      'emoji': newCategory['emoji'],
      'color': AppColors.categoryDefault,
      'isDefault': false,
      'firestoreId': docRef.id,
    };

    // Agregar a la lista local si no existe ya
    if (!categories.any((c) => c['id'] == docRef.id)) {
      categories.add(category);
      await _saveCategoriesToLocal();
    }

    return category;
  }

  // Método para eliminar una categoría y sincronizar la eliminación
  Future<void> deleteCategory(String categoryId) async {
    // Verificar si es una categoría predeterminada
    if (defaultCategories.any((cat) => cat['id'] == categoryId)) {
      throw Exception(AppStrings.defaultCategoryDeleteError);
    }

    // Eliminar de Firestore
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .delete();

    // Eliminar de la lista local
    categories.removeWhere((cat) => cat['id'] == categoryId);
    await _saveCategoriesToLocal();
  }

  // Guardar categorías en SharedPreferences
  Future<void> _saveCategoriesToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Filtrar categorías predeterminadas - solo guardamos las personalizadas
      final customCategories = categories
          .where((category) => category['isDefault'] != true)
          .toList();

      // Convertir las categorías para almacenamiento
      final customCategoriesForStorage = customCategories.map((category) {
        final Map<String, dynamic> storageCategory = Map.from(category);
        // Convertir Color a int para almacenamiento
        if (storageCategory['color'] is Color) {
          storageCategory['color'] = (storageCategory['color'] as Color).value;
        }
        return storageCategory;
      }).toList();

      // Convertir a JSON y guardar
      final String encodedCategories = jsonEncode(customCategoriesForStorage);
      await prefs.setString(_localCategoriesKey, encodedCategories);
    } catch (e) {
      print('Error guardando categorías localmente: $e');
    }
  }

  // Cargar categorías desde almacenamiento local y Firestore
  Future<List<Map<String, dynamic>>> loadCategories() async {
    // Limpiar categorías antes de cargar para evitar duplicados
    categories = [...defaultCategories];
    hasLoadedCategories = false;

    try {
      // Primero, intentar cargar desde almacenamiento local
      await _loadCategoriesFromLocal();

      // Luego, intentar cargar desde Firestore si el usuario está conectado
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _loadCategoriesFromFirestore(user.uid);
      }

      hasLoadedCategories = true;
    } catch (e) {
      print('Error cargando categorías: $e');
      // Asegurar que al menos las categorías predeterminadas estén disponibles
      if (categories.isEmpty) {
        categories = [...defaultCategories];
      }
    }

    return categories;
  }

  // Cargar categorías desde almacenamiento local
  Future<void> _loadCategoriesFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encodedCategories = prefs.getString(_localCategoriesKey);

      if (encodedCategories != null) {
        final List<dynamic> decodedCategories = jsonDecode(encodedCategories);

        // Convertir al formato correcto y añadir a categorías
        for (var item in decodedCategories) {
          final categoryId = item['id'];
          
          // Verificar que no exista ya una categoría con este ID
          if (!categories.any((c) => c['id'] == categoryId)) {
            categories.add({
              'id': categoryId,
              'name': item['name'],
              'emoji': item['emoji'],
              'color': Color(item['color'] ?? 0xFF000000), // Convertir int a Color
              'isDefault': item['isDefault'] ?? false,
              'firestoreId': item['firestoreId'], // Preservar ID de Firestore si existe
            });
          }
        }
      }
    } catch (e) {
      print('Error cargando categorías desde almacenamiento local: $e');
    }
  }

  // Cargar categorías desde Firestore y sincronizar con local
  Future<void> _loadCategoriesFromFirestore(String userId) async {
    try {
      // Cargar categorías personalizadas desde Firestore
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        final String categoryId = doc.id;
        final data = doc.data() as Map<String, dynamic>;
        
        // Verificar si esta categoría ya está en nuestra lista
        if (!categories.any((c) => c['id'] == categoryId)) {
          categories.add({
            'id': categoryId,
            'name': data['name'] ?? 'Sin nombre',
            'emoji': data['emoji'] ?? '📁',
            'color': AppColors.categoryDefault,
            'isDefault': false,
            'firestoreId': categoryId,
          });
        }
      }

      // Guardar la lista combinada de vuelta en almacenamiento local
      await _saveCategoriesToLocal();
    } catch (e) {
      print('Error cargando categorías desde Firestore: $e');
    }
  }

  // Forzar recarga de categorías
  Future<List<Map<String, dynamic>>> reloadCategories() async {
    // Limpiar las categorías y volver a cargarlas
    categories = [...defaultCategories];
    hasLoadedCategories = false;
    return await loadCategories();
  }

  // Verificar si una categoría es predeterminada
  bool isDefaultCategory(String categoryId) {
    return defaultCategories.any((cat) => cat['id'] == categoryId);
  }

  // Obtener la lista de categorías predeterminadas
  List<Map<String, dynamic>> getDefaultCategories() {
    return [...defaultCategories];
  }
}