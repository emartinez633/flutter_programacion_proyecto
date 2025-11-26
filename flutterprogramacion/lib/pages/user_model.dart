import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String password;
  Map<String, dynamic> routines; // <--- CAMBIO AQUÍ: Ahora es un Mapa
  String themeColor;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
    required this.routines,
    required this.themeColor,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      password: data['password']?.toString() ?? '',
      // Convertimos el mapa de Firebase a un Mapa de Dart seguro
      routines: data['routines'] != null 
          ? Map<String, dynamic>.from(data['routines']) 
          : {}, 
      themeColor: data['themeColor']?.toString() ?? 'blue',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'routines': routines, // Firebase acepta mapas directamente
      'themeColor': themeColor,
    };
  }
}