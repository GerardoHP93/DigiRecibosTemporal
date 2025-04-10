// lib/data/services/profile_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Servicio para gestionar los datos del perfil de usuario
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Propiedades para almacenar los datos del usuario en caché
  String? _username;
  String? _email;
  String? _profileImageUrl;

  // Singleton pattern
  factory ProfileService() {
    return _instance;
  }

  ProfileService._internal();

  /// Obtener el nombre de usuario actual
  Future<String> getUsername() async {
    // Si ya tenemos el nombre de usuario en caché, lo devolvemos
    if (_username != null) {
      return _username!;
    }

    // Obtener el usuario autenticado
    final User? user = _auth.currentUser;
    if (user == null) {
      return 'Usuario';
    }

    try {
      // Intentar obtener el nombre de usuario desde Firestore
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('username')) {
          _username = userData['username'];
          return userData['username'];
        }
      }

      // Si no hay datos en Firestore, usar email como nombre de usuario por defecto
      _username = user.email?.split('@')[0] ?? 'Usuario';
      return _username!;
    } catch (e) {
      debugPrint('Error obteniendo nombre de usuario: $e');
      _username = user.email?.split('@')[0] ?? 'Usuario';
      return _username!;
    }
  }

  /// Obtener el email del usuario actual
  String? getEmail() {
    // Si ya tenemos el email en caché, lo devolvemos
    if (_email != null) {
      return _email;
    }

    // Obtener el usuario autenticado
    final User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    _email = user.email;
    return _email;
  }

  /// Obtener la URL de la imagen de perfil
  Future<String?> getProfileImageUrl() async {
    // Si ya tenemos la URL en caché, la devolvemos
    if (_profileImageUrl != null) {
      return _profileImageUrl;
    }

    // Obtener el usuario autenticado
    final User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      // Intentar obtener la URL desde Firestore
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('profileImageUrl')) {
          _profileImageUrl = userData['profileImageUrl'];
          return _profileImageUrl;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error obteniendo URL de imagen de perfil: $e');
      return null;
    }
  }

  /// Actualizar el nombre de usuario
  Future<bool> updateUsername(String newUsername) async {
    if (newUsername.trim().isEmpty) {
      return false;
    }

    // Obtener el usuario autenticado
    final User? user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      // Actualizar el nombre de usuario en Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'username': newUsername.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _username = newUsername.trim();
      return true;
    } catch (e) {
      debugPrint('Error actualizando nombre de usuario: $e');
      return false;
    }
  }

  /// Subir una nueva imagen de perfil
  Future<String?> uploadProfileImage(File imageFile) async {
    // Obtener el usuario autenticado
    final User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      // Crear referencia en Storage
      final fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('profile_images').child(fileName);

      // Subir el archivo
      final uploadTask = storageRef.putFile(imageFile);

      // Esperar a que se complete la carga
      final snapshot = await uploadTask;

      // Obtener URL de descarga
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Actualizar en Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _profileImageUrl = downloadUrl;
      return downloadUrl;
    } catch (e) {
      debugPrint('Error subiendo imagen de perfil: $e');
      return null;
    }
  }

  /// Cargar todos los datos del perfil
  Future<Map<String, dynamic>> loadUserProfile() async {
    // Obtener el usuario autenticado
    final User? user = _auth.currentUser;
    if (user == null) {
      return {
        'username': 'Usuario',
        'email': '',
        'profileImageUrl': '',
      };
    }

    try {
      // Intentar obtener los datos desde Firestore
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;

        _username =
            userData['username'] ?? user.email?.split('@')[0] ?? 'Usuario';
        _email = user.email;
        _profileImageUrl = userData['profileImageUrl'];

        return {
          'username': _username,
          'email': _email,
          'profileImageUrl': _profileImageUrl,
        };
      }

      // Si no hay datos en Firestore, crear un perfil básico
      _username = user.email?.split('@')[0] ?? 'Usuario';
      _email = user.email;

      return {
        'username': _username,
        'email': _email,
        'profileImageUrl': '',
      };
    } catch (e) {
      debugPrint('Error cargando perfil de usuario: $e');

      _username = user.email?.split('@')[0] ?? 'Usuario';
      _email = user.email;

      return {
        'username': _username,
        'email': _email,
        'profileImageUrl': '',
      };
    }
  }

  /// Limpiar caché
  void clearCache() {
    _username = null;
    _email = null;
    _profileImageUrl = null;
  }
}