import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    // Ocultar teclado al presionar login
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final provider = Provider.of<UserProvider>(context, listen: false);
    bool success = await provider.login(
      _emailController.text.trim(),
      _passController.text.trim(),
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Credenciales incorrectas"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    // Si es exitoso, el main.dart cambiará automáticamente a HomeScreen

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un degradado oscuro para dar sensación de "Gym Premium"
    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo con degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blueGrey.shade900, // Color oscuro superior
                  Colors.black87, // Color oscuro inferior
                ],
              ),
            ),
          ),

          // 2. Contenido Centrado
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- LOGO / ICONO ---
                  Icon(
                    Icons.fitness_center, // Ícono de mancuerna
                    size: 100,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "FIT TRACKER",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Text(
                    "Entrena sin límites",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 50),

                  // --- INPUT EMAIL ---
                  _buildCustomTextField(
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    hintText: "Correo electrónico",
                    isPassword: false,
                  ),

                  SizedBox(height: 20),

                  // --- INPUT PASSWORD ---
                  _buildCustomTextField(
                    controller: _passController,
                    icon: Icons.lock_outline,
                    hintText: "Contraseña",
                    isPassword: true,
                  ),

                  SizedBox(height: 40),

                  // --- BOTÓN LOGIN ---
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.orangeAccent)
                      : SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .orangeAccent, // Color de acento deportivo
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              "INICIAR SESIÓN",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para no repetir código en los Inputs
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required bool isPassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Fondo semitransparente
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }
}
