// lib/features/settings/screens/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/shared/widgets/decorative_background.dart';
import 'package:digirecibos/shared/widgets/app_bottom_navigation.dart';
import 'package:digirecibos/shared/widgets/app_header.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  String _username = '';
  String _email = '';
  String _profileImageUrl = '';

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  File? _imageFile;

  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        // Obtener datos del usuario desde Firestore
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            _username =
                userData['username'] ?? user.email?.split('@')[0] ?? 'Usuario';
            _email = user.email ?? '';
            _profileImageUrl = userData['profileImageUrl'] ?? '';
            _usernameController.text = _username;
          });
        } else {
          setState(() {
            _username = user.email?.split('@')[0] ?? 'Usuario';
            _email = user.email ?? '';
            _usernameController.text = _username;
          });
        }
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos del perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUsername() async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingresa un nombre de usuario válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_usernameController.text.trim() == _username) {
      // No hay cambios
      setState(() {
        _isEditing = false;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': _usernameController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        setState(() {
          _username = _usernameController.text.trim();
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nombre de usuario actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error al actualizar nombre de usuario: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar nombre de usuario: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      // Intentar seleccionar la imagen directamente, lo que provocará
      // el diálogo nativo de permisos la primera vez
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });

        await _uploadProfileImage();
      }
    } catch (e) {
      print('Error al seleccionar la imagen: $e');

      // Si falla por permisos, verificamos si está permanentemente denegado
      PermissionStatus galleryStatus = await Permission.photos.status;

      if (galleryStatus.isPermanentlyDenied) {
        // Si está permanentemente denegado, mostramos la opción para ir a configuración
        _showOpenSettingsDialog();
      } else {
        // Para otros errores, mostramos un mensaje genérico
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al acceder a la galería. Por favor intenta nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOpenSettingsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Permiso de galería',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Para cambiar tu foto de perfil, la aplicación necesita acceso a tu galería. Por favor, concede el permiso en la configuración de tu dispositivo.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Ir a Configuración'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      openAppSettings();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        // Crear referencia en Storage
        final storageRef = _storage
            .ref()
            .child('profile_images')
            .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

        // Subir el archivo
        final uploadTask = storageRef.putFile(_imageFile!);

        // Esperar a que se complete la carga
        final snapshot = await uploadTask;

        // Obtener URL de descarga
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Actualizar en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'profileImageUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        setState(() {
          _profileImageUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen de perfil actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error al subir la imagen de perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir la imagen de perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
        _imageFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Evita que el contenido se desplace cuando aparece el teclado
      body: DecorativeBackground(
        child: Column(
          children: [
            // Usar el nuevo header unificado
            AppHeader(
              title: 'Tu perfil',
              onBackPress: () => Navigator.pop(context),
            ),
            
            // Contenido principal
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProfileContent(),
            ),
            
            // Bottom navigation bar
            AppBottomNavigation(
              currentIndex: 2, // Mantener el índice de "Ajustes"
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: AppDimens.paddingL),

            // Foto de perfil
            _buildProfileImage(),

            SizedBox(height: AppDimens.paddingL),

            // Nombre de usuario
            Card(
              elevation: AppDimens.elevationM,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppDimens.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de usuario',
                      style: AppTextStyles.subtitle,
                    ),
                    SizedBox(height: AppDimens.paddingL),

                    // Campo de nombre de usuario
                    _buildUserNameField(),

                    SizedBox(height: AppDimens.paddingL),

                    // Email (solo lectura)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimens.fontM,
                          ),
                        ),
                        SizedBox(height: AppDimens.paddingS),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimens.paddingL,
                            vertical: AppDimens.paddingM,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusM),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            _email,
                            style: TextStyle(
                              fontSize: AppDimens.fontM,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nombre Usuario',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppDimens.fontM,
              ),
            ),
            if (_isSaving)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            else
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.check : Icons.edit,
                  color: AppColors.primary,
                ),
                onPressed: _isSaving
                    ? null
                    : () {
                        if (_isEditing) {
                          _updateUsername();
                        } else {
                          setState(() {
                            _isEditing = true;
                          });
                        }
                      },
                tooltip: _isEditing ? 'Guardar' : 'Editar',
              ),
          ],
        ),
        SizedBox(height: AppDimens.paddingS),
        if (_isEditing)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingL,
                      vertical: AppDimens.paddingM,
                    ),
                  ),
                  enabled: !_isSaving,
                  autofocus: true,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: _isSaving
                    ? null
                    : () {
                        setState(() {
                          _usernameController.text = _username;
                          _isEditing = false;
                        });
                      },
                tooltip: 'Cancelar',
              ),
            ],
          )
        else
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.paddingL,
              vertical: AppDimens.paddingM,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _username,
              style: TextStyle(fontSize: AppDimens.fontM),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withOpacity(0.3),
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!) as ImageProvider
                  : _profileImageUrl.isNotEmpty
                      ? NetworkImage(_profileImageUrl) as ImageProvider
                      : AssetImage('assets/profile.jpg'),
              child: _isSaving
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : null,
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white),
                onPressed: _isSaving ? null : _pickImage,
                tooltip: 'Cambiar foto de perfil',
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimens.paddingM),
        Text(
          'Toca para cambiar tu foto',
          style: TextStyle(
            fontSize: AppDimens.fontS,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}