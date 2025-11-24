import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _currentUser;

  UserProfile? get currentUser => _currentUser;

  // Lógica para convertir el String de la DB a un Color de Flutter
  Color get currentThemeColor {
    // Protección: Si es null, devuelve azul por defecto
    if (_currentUser == null) return Colors.blue;
    
    switch (_currentUser!.themeColor.toLowerCase()) {
      case 'blue': return Colors.blue;
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'black': return Colors.black; // Agregué black porque lo usas en el Dropdown
      default: return Colors.blue;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _currentUser = UserProfile.fromFirestore(querySnapshot.docs.first);
        notifyListeners(); 
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Actualizar Rutinas y Color
  Future<void> updateProfile(Map<String, dynamic> newRoutines, String newColor) async {
    if (_currentUser == null) return;

    // 1. Actualizamos el objeto localmente para que la UI cambie rápido
    _currentUser!.routines = newRoutines;
    _currentUser!.themeColor = newColor;
    
    // Notificamos para que la app cambie de color inmediatamente
    notifyListeners(); 

    // 2. Enviamos a Firebase
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.id)
        .update({
          'routines': newRoutines,
          'themeColor': newColor,
        });
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}