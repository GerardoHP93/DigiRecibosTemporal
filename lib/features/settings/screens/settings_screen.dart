// lib/features/settings/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digirecibos/core/constants/app_colors.dart';
import 'package:digirecibos/core/constants/app_dimens.dart';
import 'package:digirecibos/core/constants/app_text_styles.dart';
import 'package:digirecibos/shared/widgets/decorative_background.dart';
import 'package:digirecibos/shared/widgets/app_bottom_navigation.dart';
import 'package:digirecibos/shared/widgets/user_header.dart';
import 'package:digirecibos/features/settings/screens/profile_screen.dart';
import 'package:digirecibos/features/auth/screens/login_screen.dart';
import 'package:digirecibos/features/settings/widgets/settings_button.dart';
import 'package:digirecibos/features/settings/screens/about_screen.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = 'Usuario';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUsernameFromFirestore();
  }

  Future<void> _getUsernameFromFirestore() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Intentar obtener el nombre de usuario desde Firestore
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

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
          username = user.email?.split('@')[0] ?? 'Usuario';
          isLoading = false;
        });
      } catch (e) {
        print('Error obteniendo el nombre de usuario: $e');
        setState(() {
          username = user.email?.split('@')[0] ?? 'Usuario';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar sesión'),
        content: Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      print('Error al cerrar sesión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppDimens.paddingL),

              // Header con imagen de perfil y saludo
              UserHeader(
                username: username,
                isLoading: isLoading,
              ),

              SizedBox(height: AppDimens.paddingXL),

              // Título de la sección
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
                child: Text(
                  'Ajustes',
                  style: TextStyle(
                    fontSize: AppDimens.fontXXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: AppDimens.paddingL),

              // Botones de configuración
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
                  child: Column(
                    children: [
                      // Botón de Perfil usando SettingsButton
                      SettingsButton(
                        text: 'Perfil',
                        onPressed: _navigateToProfile,
                      ),

                      SizedBox(height: AppDimens.paddingL),

                      // Botón de Acerca de usando SettingsButton
                      SettingsButton(
                        text: 'Acerca de',
                        onPressed: _navigateToAbout,
                      ),

                      SizedBox(height: AppDimens.paddingL),

                      // Botón de Cerrar sesión usando SettingsButton
                      SettingsButton(
                        text: 'Cerrar sesión',
                        onPressed: _showLogoutDialog,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2, // Índice para "Ajustes"
      ),
    );
  }
}
