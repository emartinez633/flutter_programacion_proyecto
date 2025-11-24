import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'pages/user_provider.dart';
import 'pages/login_screen.dart';
import 'pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Asegúrate de tener tu google-services.json configurado
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el Provider en el árbol de widgets
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return MaterialApp(
            title: 'Gym Tracker',
            debugShowCheckedModeBanner: false,
            // Aquí es donde ocurre la magia de la personalización dinámica
            theme: ThemeData(
              primarySwatch: userProvider.currentThemeColor as MaterialColor,
              appBarTheme: AppBarTheme(
                backgroundColor: userProvider.currentThemeColor,
              ),
            ),
            home: userProvider.currentUser == null 
                ? LoginScreen() 
                : HomeScreen(),
          );
        },
      ),
    );
  }
}