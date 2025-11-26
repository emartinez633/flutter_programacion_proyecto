import 'dart:async';
import 'package:flutter/material.dart';

class WorkoutScreen extends StatefulWidget {
  final String exerciseName;
  final int targetReps;
  final int targetSeries;
  final Color themeColor;

  const WorkoutScreen({
    Key? key,
    required this.exerciseName,
    required this.targetReps,
    required this.targetSeries,
    required this.themeColor,
  }) : super(key: key);

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // Configuración inicial
  bool _isSetupMode = true;
  bool _isTimerMode = true;
  final _timeController = TextEditingController();
  final _weightController = TextEditingController();
  bool _requiresWeight = false;

  // Estado del Entrenamiento
  Timer? _timer;
  int _totalTime = 0;
  int _currentTime = 0;

  int _currentSeries = 1;
  int _currentRep = 1;
  bool _isTimerRunning = false;
  
  // Estados de control
  bool _isResting = false; 
  bool _isPaused = false; 

  @override
  void dispose() {
    _timer?.cancel();
    _timeController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // --- LÓGICA PRINCIPAL (Sin cambios funcionales) ---

  void _startWorkout() {
    if (_isTimerMode && _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ingresa el tiempo por repetición")));
      return;
    }

    if (_requiresWeight && _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Ingresa el peso")));
      return;
    }

    setState(() {
      if (_isTimerMode) {
        _totalTime = int.parse(_timeController.text);
        _currentTime = _totalTime;
        _startTimer();
      }
      _isSetupMode = false;
    });
  }

  void _startTimer() {
    _isTimerRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      setState(() {
        if (_currentTime > 0) {
          _currentTime--;
        } else {
          _timer?.cancel();
          _isTimerRunning = false;
          _handleAutoAdvance(); 
        }
      });
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _triggerTimedPause(int seconds) {
    if (_isPaused) return;

    setState(() {
      _isPaused = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.timer, color: Colors.white),
            SizedBox(width: 10),
            Text("Descanso de $seconds segundos..."),
          ],
        ),
        duration: Duration(seconds: seconds),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Timer(Duration(seconds: seconds), () {
      if (mounted) {
        setState(() {
          _isPaused = false;
        });
      }
    });
  }

  void _handleAutoAdvance() {
    setState(() {
      _isResting = true; 
    });

    Timer(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isResting = false; 
        });
        _nextRepetition();
      }
    });
  }

  void _showFinishedWorkoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("¡Entrenamiento Completo!", style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 60, color: Colors.amber),
            SizedBox(height: 10),
            Text("Has terminado todas las series con éxito."),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: widget.themeColor),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text("Finalizar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _nextRepetition() {
    setState(() {
      if (_currentRep < widget.targetReps) {
        _currentRep++;
      } else {
        if (_currentSeries < widget.targetSeries) {
          _currentSeries++;
          _currentRep = 1;
        } else {
          _showFinishedWorkoutDialog();
          return;
        }
      }

      if (_isTimerMode) {
        _currentTime = _totalTime;
        _isPaused = false;
        _startTimer();
      }
    });
  }

  // --- VISTAS ---

  Widget _buildSetupView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.themeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.settings_accessibility, size: 60, color: widget.themeColor),
            ),
            SizedBox(height: 20),
            Text(
              "Configuración",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87),
            ),
            SizedBox(height: 5),
            Text(
              "${widget.exerciseName}",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            Text(
              "${widget.targetSeries} Series x ${widget.targetReps} Reps",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 40),
      
            // Panel de configuración estilizado
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  Text("Modo de ejecución", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text("Tiempo", style: TextStyle(fontSize: 14)),
                          activeColor: widget.themeColor,
                          value: true,
                          groupValue: _isTimerMode,
                          onChanged: (val) => setState(() => _isTimerMode = val!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text("Manual", style: TextStyle(fontSize: 14)),
                          activeColor: widget.themeColor,
                          value: false,
                          groupValue: _isTimerMode,
                          onChanged: (val) => setState(() => _isTimerMode = val!),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  if (_isTimerMode)
                    TextField(
                      controller: _timeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Segundos por repetición",
                        border: InputBorder.none,
                        icon: Icon(Icons.timer, color: widget.themeColor),
                      ),
                    ),
                  if (_isTimerMode) Divider(),
                  Row(
                    children: [
                      Icon(Icons.fitness_center, color: widget.themeColor),
                      SizedBox(width: 15),
                      Text("¿Requiere peso?"),
                      Spacer(),
                      Switch(
                        value: _requiresWeight,
                        activeColor: widget.themeColor,
                        onChanged: (val) => setState(() => _requiresWeight = val),
                      ),
                    ],
                  ),
                  if (_requiresWeight)
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Peso (kg/lbs)",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 40),
                      ),
                    ),
                ],
              ),
            ),
      
            SizedBox(height: 40),
      
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _startWorkout,
                child: Text(
                  "INICIAR ENTRENAMIENTO",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 100, color: Colors.green),
          ),
          SizedBox(height: 30),
          Text(
            "¡BIEN HECHO!",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.green, letterSpacing: 1.5),
          ),
          SizedBox(height: 10),
          Text("Prepárate para la siguiente...", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  // --- WIDGET DEL CRONÓMETRO DEPORTIVO ---
  Widget _buildStopwatchFace({required Widget centerContent, required double progress}) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none, // Permite dibujar fuera del stack (el botón superior)
      children: [
        // 1. El "Botón" físico del cronómetro arriba
        Positioned(
          top: -20,
          child: Container(
            width: 20,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey[600]!, width: 2),
            ),
          ),
        ),
        // 2. Botones laterales decorativos (orejas)
        Positioned(
          top: 10,
          right: 30,
          child: Transform.rotate(
            angle: 0.5,
            child: Container(width: 15, height: 25, color: Colors.grey[400]),
          ),
        ),

        // 3. Sombra externa (Cuerpo del reloj)
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
              BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(-5, -5)),
            ],
          ),
        ),

        // 4. Anillo de progreso
        SizedBox(
          width: 250,
          height: 250,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 15,
            backgroundColor: Colors.grey[300],
            color: _isPaused ? Colors.orangeAccent : widget.themeColor,
            strokeCap: StrokeCap.round, // Bordes redondeados en la barra
          ),
        ),

        // 5. Carátula Oscura (Fondo del display)
        Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black87, // Fondo oscuro estilo reloj digital
            border: Border.all(color: Colors.grey[800]!, width: 5),
            boxShadow: [
              BoxShadow(color: Colors.black, blurRadius: 10), // Sombra interna
            ],
          ),
          child: Center(child: centerContent),
        ),
      ],
    );
  }

  Widget _buildTimerView() {
    if (_isResting) return _buildRestingView();

    double progress = _totalTime > 0 ? _currentTime / _totalTime : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoHeader(),
        
        // EL CRONÓMETRO
        _buildStopwatchFace(
          progress: progress,
          centerContent: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de estado
              if (_isPaused)
                Icon(Icons.pause, color: Colors.orangeAccent, size: 30)
              else
                Icon(Icons.timer, color: Colors.white24, size: 30),
              
              SizedBox(height: 5),
              
              // NÚMEROS DIGITALES
              Text(
                "$_currentTime",
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'monospace', // Fuente tipo digital
                  letterSpacing: -2,
                ),
              ),
              Text(
                _isPaused ? "PAUSADO" : "SEGUNDOS",
                style: TextStyle(
                  color: _isPaused ? Colors.orangeAccent : Colors.grey,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // CONTROLES DE REPRODUCCIÓN
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRoundButton(
                icon: Icons.timer_10,
                color: Colors.orange[100]!,
                iconColor: Colors.orange[800]!,
                label: "+10s",
                onTap: () => _triggerTimedPause(10),
              ),
              _buildRoundButton(
                icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: widget.themeColor,
                iconColor: Colors.white,
                size: 70, // Más grande
                onTap: _togglePause,
              ),
              _buildRoundButton(
                icon: Icons.stop_rounded,
                color: Colors.red[100]!,
                iconColor: Colors.red,
                label: "Fin",
                onTap: _confirmCancel,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualView() {
    if (_isResting) return _buildRestingView();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoHeader(),
        
        // Usamos el mismo estilo de cronómetro pero con un botón dentro
        _buildStopwatchFace(
          progress: 1.0, // Círculo completo
          centerContent: InkWell(
            onTap: () => _handleAutoAdvance(),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: 210,
              height: 210,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, size: 50, color: widget.themeColor),
                  SizedBox(height: 10),
                  Text(
                    "TERMINAR",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "REPETICIÓN",
                    style: TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),

        TextButton.icon(
          icon: Icon(Icons.close, color: Colors.red),
          label: Text("CANCELAR SERIE", style: TextStyle(fontWeight: FontWeight.bold)),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: _confirmCancel,
        ),
      ],
    );
  }

  // Widget para los botones circulares inferiores
  Widget _buildRoundButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    String? label,
    double size = 50,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))
              ],
            ),
            child: Icon(icon, color: iconColor, size: size * 0.5),
          ),
        ),
        if (label != null) ...[
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        ]
      ],
    );
  }

  Widget _buildInfoHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoItem("SERIE", "$_currentSeries / ${widget.targetSeries}"),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          _infoItem("REP", "$_currentRep / ${widget.targetReps}"),
          if (_requiresWeight) ...[
            Container(width: 1, height: 30, color: Colors.grey[300]),
            _infoItem("PESO", "${_weightController.text}kg"),
          ],
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  void _confirmCancel() {
    bool wasPaused = _isPaused;
    _isPaused = true; 

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("¿Detener?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Se perderá el progreso actual."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (!wasPaused) setState(() => _isPaused = false);
            },
            child: Text("Continuar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text("Salir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSetupMode) return true;
        _confirmCancel();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100], // Fondo claro general para contraste
        appBar: AppBar(
          title: Text(
            _isSetupMode ? "PREPARACIÓN" : widget.exerciseName.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: _isSetupMode 
            ? _buildSetupView() 
            : (_isTimerMode ? _buildTimerView() : _buildManualView()),
      ),
    );
  }
}