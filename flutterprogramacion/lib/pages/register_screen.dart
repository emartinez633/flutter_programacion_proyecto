import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    FocusScope.of(context).unfocus(); // Bajar teclado

    // Validaciones básicas
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passController.text.isEmpty) {
      _showError("Por favor completa todos los campos");
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      _showError("Las contraseñas no coinciden");
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<UserProvider>(context, listen: false);
    
    // Llamamos a la nueva función register
    bool success = await provider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passController.text.trim(),
    );

    if (success) {
      // Si el registro es exitoso, Provider notifica y main.dart redirige a Home
      // Pero debemos limpiar el historial de navegación para que no pueda volver atrás
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      _showError("El correo ya está registrado o hubo un error");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Extendemos el body detrás del AppBar para mantener el degradado completo
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // 1. Fondo Degradado (Idéntico al Login)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blueGrey.shade900,
                  Colors.black87,
                ],
              ),
            ),
          ),

          // 2. Formulario
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add, // Ícono diferente para registro
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "CREAR CUENTA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "Únete al equipo",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 40),

                  // Inputs reutilizando el estilo
                  _buildCustomTextField(
                    controller: _nameController,
                    icon: Icons.person_outline,
                    hintText: "Nombre Completo",
                    isPassword: false,
                  ),
                  SizedBox(height: 15),
                  _buildCustomTextField(
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    hintText: "Correo electrónico",
                    isPassword: false,
                  ),
                  SizedBox(height: 15),
                  _buildCustomTextField(
                    controller: _passController,
                    icon: Icons.lock_outline,
                    hintText: "Contraseña",
                    isPassword: true,
                  ),
                  SizedBox(height: 15),
                  _buildCustomTextField(
                    controller: _confirmPassController,
                    icon: Icons.lock_reset,
                    hintText: "Confirmar Contraseña",
                    isPassword: true,
                  ),

                  SizedBox(height: 40),

                  _isLoading
                      ? CircularProgressIndicator(color: Colors.orangeAccent)
                      : SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              "REGISTRARME",
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

  // Widget auxiliar de estilo (Mismo que en Login)
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required bool isPassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
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