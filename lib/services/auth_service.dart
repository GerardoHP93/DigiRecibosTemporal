import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registro de usuario con correo, contraseña y username
  Future<Map<String, dynamic>> registerUser(String email, String password, String username) async {
    try {
      // Validar que todos los campos estén completos (aunque también lo haremos en la UI)
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        return {
          'success': false,
          'message': 'Todos los campos son obligatorios',
          'user': null
        };
      }

      // 1. Registrar usuario en Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
     
      // 2. Si el registro fue exitoso, guardar información adicional en Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': username,
          'email': email,
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
     
      return {
        'success': true,
        'message': 'Registro exitoso',
        'user': userCredential.user
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al registrarse';
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Este correo electrónico ya está registrado';
          break;
        case 'invalid-email':
          errorMessage = 'El formato del correo electrónico es inválido';
          break;
        case 'weak-password':
          errorMessage = 'La contraseña debe tener al menos 8 caracteres, incluir mayúsculas, minúsculas y números';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Operación no permitida. Contacta al administrador';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'user': null
      };
    } catch (e) {
      print(e);
      return {
        'success': false,
        'message': 'Error inesperado al registrarse',
        'user': null
      };
    }
  }

  // Inicio de sesión modificado para verificar email y mejorar mensajes de error
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      // Validar que todos los campos estén completos (aunque también lo haremos en la UI)
      if (email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Debes completar todos los campos',
          'user': null
        };
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
     
      // Recargar usuario para obtener estado actualizado de verificación
      await userCredential.user!.reload();
     
      if (!userCredential.user!.emailVerified) {
        return {
          'success': false,
          'message': 'email_not_verified',
          'user': userCredential.user
        };
      }
     
      return {
        'success': true,
        'message': 'login_success',
        'user': userCredential.user
      };
    } on FirebaseAuthException catch (e) {
      print(e.code);
      String errorMessage = 'Error al iniciar sesión';
     
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          // Por seguridad, no especificamos si el usuario no existe o la contraseña es incorrecta
          errorMessage = 'Datos de acceso inválidos';
          break;
        case 'invalid-email':
          errorMessage = 'El formato del correo electrónico es inválido';
          break;
        case 'user-disabled':
          errorMessage = 'Esta cuenta ha sido deshabilitada';
          break;
        case 'too-many-requests':
          errorMessage = 'Demasiados intentos fallidos. Intenta más tarde';
          break;
        default:
          errorMessage = 'Error al iniciar sesión';
      }
     
      return {
        'success': false,
        'message': errorMessage,
        'user': null
      };
    } catch (e) {
      print(e);
      return {
        'success': false,
        'message': 'Error inesperado al iniciar sesión',
        'user': null
      };
    }
  }

  // Verificar si el correo está verificado
  bool isEmailVerified() {
    User? user = _auth.currentUser;
    return user != null && user.emailVerified;
  }

  // Reenviar correo de verificación
  Future<bool> resendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Actualizar el estado de verificación en Firestore
  Future<void> updateEmailVerificationStatus() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Recargar el usuario para obtener el estado actual
        await user.reload();
        user = _auth.currentUser;
        if (user != null && user.emailVerified) {
          await _firestore.collection('users').doc(user.uid).update({
            'emailVerified': true
          });
          print("Estado de verificación actualizado en Firestore: ${user.emailVerified}");
        }
      }
    } catch (e) {
      print("Error al actualizar estado de verificación: $e");
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Restablecer contraseña
Future<void> resetPassword(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
  } on FirebaseAuthException catch (e) {
    print('Error al enviar el correo de restablecimiento: ${e.code}');
    
    // Manejo de errores específicos de Firebase
    switch (e.code) {
      case 'invalid-email':
        throw 'El formato del correo electrónico es inválido.';
      case 'user-not-found':
        throw 'No hay ningún usuario registrado con este correo electrónico.';
      case 'too-many-requests':
        throw 'Demasiados intentos. Por favor, intenta más tarde.';
      default:
        throw 'Error al enviar el correo de restablecimiento. Por favor, inténtalo de nuevo.';
    }
  } catch (e) {
    print('Error inesperado: $e');
    throw 'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';
  }
}
}