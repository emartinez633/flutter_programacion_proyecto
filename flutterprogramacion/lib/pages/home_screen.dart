import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'workout_screen.dart';
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

      final validColors = ['blue', 'red', 'green', 'purple', 'orange', 'grey'];
      if (validColors.contains(user.themeColor)) {
        _selectedColor = user.themeColor;
      } else {
        _selectedColor = 'blue';
      }
    }
  }

  Color _getColorObject(String colorName) {
    switch (colorName) {
      case 'blue': return Colors.blue;
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'grey': return Colors.grey;
      default: return Colors.blue;
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
            Text("Guardado exitoso"),
          ],
        ),
        backgroundColor: _getColorObject(_selectedColor),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _syncWithFirebase() {
    Provider.of<UserProvider>(
      context,
      listen: false,
    ).updateProfile(_localRoutines, _selectedColor);
  }

  void _showAddExerciseDialog({
    String? existingKey,
    String? existingExerciseName,
    int? existingReps,
    int? existingSeries,
  }) {
    final keyController = TextEditingController(text: existingKey);
    final exerciseNameController = TextEditingController(text: existingExerciseName);
    final repsController = TextEditingController(text: existingReps?.toString() ?? '');
    final seriesController = TextEditingController(text: existingSeries?.toString() ?? '');
    
    // Variable para saber si estamos editando
    bool isEditing = existingKey != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEditing ? "Editar Rutina" : "Nueva Rutina"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. CAMPO DÍA / ID
              TextField(
                controller: keyController,
                enabled: true, 
                decoration: InputDecoration(
                  labelText: "Día / ID",
                  hintText: "Ej: Lunes",
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 15),
              
              // 2. NOMBRE EJERCICIO
              TextField(
                controller: exerciseNameController,
                decoration: InputDecoration(
                  labelText: "Ejercicio",
                  hintText: "Ej: Press Banca",
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 15),
              
              // 3. SERIES Y REPS
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: seriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Series",
                        hintText: "4",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Reps",
                        hintText: "12",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _getColorObject(_selectedColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (keyController.text.isNotEmpty &&
                  exerciseNameController.text.isNotEmpty &&
                  repsController.text.isNotEmpty &&
                  seriesController.text.isNotEmpty) {
                
                setState(() {
                  // Lógica para renombrar clave si cambió
                  if (isEditing && existingKey != keyController.text) {
                    _localRoutines.remove(existingKey);
                  }

                  _localRoutines[keyController.text] = {
                    'Ejercicio': exerciseNameController.text,
                    'Repeticiones': int.tryParse(repsController.text) ?? 0,
                    'Series': int.tryParse(seriesController.text) ?? 0,
                  };
                });
                
                _syncWithFirebase();
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
    _syncWithFirebase();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("¿Cerrar Sesión?"),
        content: Text("Tendrás que ingresar tus datos nuevamente."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Provider.of<UserProvider>(context, listen: false).logout();
            },
            child: Text("Salir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- WIDGET AUXILIAR PARA ESTADÍSTICAS (Badge) ---
  Widget _buildStatBadge(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              SizedBox(width: 5),
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
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
      backgroundColor: Colors.grey[50], // Fondo claro para contraste
      body: Column(
        children: [
          // --- HEADER ---
          Container(
            padding: EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 15, offset: Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bienvenido,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        Text(user?.name ?? 'Atleta', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(Icons.logout, color: Colors.white),
                        onPressed: _confirmLogout,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 25),
                // TOOLBAR (Color y Guardar)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.palette, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedColor,
                          dropdownColor: themeColor,
                          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          items: ['blue', 'red', 'green', 'purple', 'orange', 'grey']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedColor = v!);
                            _saveChanges();
                          },
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: _saveChanges,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              Icon(Icons.cloud_upload, color: themeColor, size: 16),
                              SizedBox(width: 5),
                              Text("GUARDAR", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      )
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
                        Icon(Icons.fitness_center, size: 60, color: Colors.grey[300]),
                        SizedBox(height: 10),
                        Text("Sin rutinas activas", style: TextStyle(color: Colors.grey[400], fontSize: 18)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: exerciseList.length,
                    itemBuilder: (context, index) {
                      String key = exerciseList[index];
                      Map<String, dynamic> data = Map<String, dynamic>.from(_localRoutines[key] ?? {});
                      
                      String exerciseName = data['Ejercicio'] ?? 'Sin Nombre';
                      int reps = data['Repeticiones'] ?? 0;
                      int series = data['Series'] ?? 0;

                      return Container(
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => WorkoutScreen(
                                    exerciseName: exerciseName,
                                    targetReps: reps,
                                    targetSeries: series,
                                    themeColor: themeColor,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // FILA SUPERIOR: ETIQUETA Y MENÚ
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: themeColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          key.toUpperCase(), // Ej: LUNES
                                          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.more_horiz, color: Colors.grey),
                                        onSelected: (String result) {
                                          if (result == 'edit') {
                                            _showAddExerciseDialog(
                                              existingKey: key,
                                              existingExerciseName: exerciseName,
                                              existingReps: reps,
                                              existingSeries: series,
                                            );
                                          } else if (result == 'delete') {
                                            _deleteExercise(key);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                                          PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: 10),
                                  
                                  // NOMBRE DEL EJERCICIO GRANDE
                                  Text(
                                    exerciseName,
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
                                  ),
                                  
                                  SizedBox(height: 20),
                                  
                                  // ESTADÍSTICAS Y BOTÓN PLAY
                                  Row(
                                    children: [
                                      _buildStatBadge(Icons.repeat, "SERIES", "$series", themeColor),
                                      SizedBox(width: 15),
                                      _buildStatBadge(Icons.refresh, "REPS", "$reps", themeColor),
                                      Spacer(),
                                      Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: themeColor,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 4)),
                                          ],
                                        ),
                                        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
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
        label: Text("Agregar Rutina"),
        icon: Icon(Icons.add),
        backgroundColor: themeColor,
        elevation: 4,
      ),
    );
  }
}