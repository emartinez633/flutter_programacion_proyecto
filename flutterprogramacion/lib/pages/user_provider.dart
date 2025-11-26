import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _currentUser;

  UserProfile? get currentUser => _currentUser;

  // Lógica para convertir el String de la DB a un Color de Flutter
  Color get currentThemeColor {
    if (_currentUser == null) return Colors.blue;
    
    switch (_currentUser!.themeColor.toLowerCase()) {
      case 'blue': return Colors.blue;
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'grey': return Colors.grey;
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

  // Registro
  Future<bool> register(String name, String email, String password) async {
    try {
      final checkUser = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (checkUser.docs.isNotEmpty) {
        return false; 
      }

      // Estructura inicial vacía. 
      // Las rutinas se irán agregando como: 
      // "Rutina_1": { "Ejercicio": "X", "Series": 1, "Repeticiones": 1 }
      Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'password': password,
        'routines': {}, 
        'themeColor': 'blue',
      };

      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('users')
          .add(userData);

      _currentUser = UserProfile(
        id: docRef.id, 
        name: name, 
        email: email, 
        password: password, 
        routines: {}, 
        themeColor: 'blue'
      );

      notifyListeners();
      return true;

    } catch (e) {
      print("Error en registro: $e");
      return false;
    }
  }

  // Actualizar Perfil
  Future<void> updateProfile(Map<String, dynamic> newRoutines, String newColor) async {
    if (_currentUser == null) return;

    _currentUser!.routines = newRoutines;
    _currentUser!.themeColor = newColor;
    
    notifyListeners(); 

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