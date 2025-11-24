import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _localRoutines = {};
  String _selectedColor = 'blue';

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _localRoutines = Map.from(user.routines);

      // Validación de seguridad para el color
      final validColors = ['blue', 'red', 'green', 'purple', 'orange', 'black'];
      if (validColors.contains(user.themeColor)) {
        _selectedColor = user.themeColor;
      } else {
        _selectedColor = 'blue';
      }
    }
  }

  // Helper para obtener el objeto Color real basado en el String
  Color _getColorObject(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'black':
        return Colors.black87;
      default:
        return Colors.blue;
    }
  }

  void _saveChanges() {
    final provider = Provider.of<UserProvider>(context, listen: false);
    provider.updateProfile(_localRoutines, _selectedColor);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text("Rutina y tema actualizados"),
          ],
        ),
        backgroundColor: _getColorObject(_selectedColor),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddExerciseDialog({String? existingName, String? existingDetails}) {
    final nameController = TextEditingController(text: existingName);
    final detailsController = TextEditingController(text: existingDetails);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          existingName == null ? "Nuevo Ejercicio" : "Editar Ejercicio",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (existingName == null)
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nombre",
                  hintText: "Ej: Sentadillas",
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            SizedBox(height: 15),
            TextField(
              controller: detailsController,
              decoration: InputDecoration(
                labelText: "Detalles",
                hintText: "Ej: 4 series x 12 reps",
                prefixIcon: Icon(Icons.list_alt),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _getColorObject(_selectedColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  detailsController.text.isNotEmpty) {
                setState(() {
                  _localRoutines[nameController.text] = detailsController.text;
                });
                Navigator.of(ctx).pop();
              }
            },
            child: Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteExercise(String key) {
    setState(() {
      _localRoutines.remove(key);
    });
  }

  // Función para mostrar la alerta de confirmación
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Text("Cerrar Sesión"),
          ],
        ),
        content: Text("¿Estás seguro de que quieres salir de tu cuenta?"),
        actions: [
          // Botón Cancelar
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          // Botón Salir (Rojo para indicar acción de salida)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // Cierra la alerta primero
              // Llama al logout del provider
              Provider.of<UserProvider>(context, listen: false).logout();
            },
            child: Text("Salir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    final exerciseList = _localRoutines.keys.toList();
    final themeColor = _getColorObject(_selectedColor);

    return Scaffold(
      backgroundColor:
          Colors.grey[100], // Fondo gris claro para resaltar tarjetas
      body: Column(
        children: [
          // --- HEADER PERSONALIZADO ---
          Container(
            padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ... dentro del Row del Header ...
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    // ESTE ES EL BOTÓN MODIFICADO:
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.white),
                      tooltip: "Cerrar sesión",
                      onPressed:
                          _confirmLogout, // <--- Aquí llamamos a la alerta
                    ),
                    // ...
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "Hola, ${user?.name ?? 'Atleta'}",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Tu plan de entrenamiento",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                SizedBox(height: 20),

                // Panel de Control (Color y Guardar) dentro del Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: _selectedColor,
                        dropdownColor: themeColor,
                        icon: Icon(Icons.palette, color: Colors.white),
                        underline: Container(), // Quitar línea fea
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        items:
                            [
                                  'blue',
                                  'red',
                                  'green',
                                  'purple',
                                  'orange',
                                  'black',
                                ]
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.toUpperCase()),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _selectedColor = v!),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.save, size: 18),
                        label: Text("GUARDAR"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor:
                              themeColor, // Texto del color del tema
                          shape: StadiumBorder(),
                        ),
                        onPressed: _saveChanges,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- LISTA DE EJERCICIOS ---
          Expanded(
            child: exerciseList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 10),
                        Text(
                          "No hay ejercicios hoy",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: exerciseList.length,
                    itemBuilder: (context, index) {
                      String key = exerciseList[index];
                      String value = _localRoutines[key];

                      return Container(
                        margin: EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.fitness_center,
                              color: themeColor,
                            ),
                          ),
                          title: Text(
                            key,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.repeat,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert),
                            onSelected: (String result) {
                              if (result == 'edit') {
                                _showAddExerciseDialog(
                                  existingName: key,
                                  existingDetails: value,
                                );
                              } else if (result == 'delete') {
                                _deleteExercise(key);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Borrar',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExerciseDialog(),
        label: Text("Agregar Ejercicio"),
        icon: Icon(Icons.add),
        backgroundColor: themeColor,
      ),
    );
  }
}
