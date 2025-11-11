import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GoalkeeperGameScreen extends StatefulWidget {
  const GoalkeeperGameScreen({super.key});

  @override
  State<GoalkeeperGameScreen> createState() => _GoalkeeperGameScreenState();
}

class _GoalkeeperGameScreenState extends State<GoalkeeperGameScreen> {
  double _keeperX = 0.0;
  double _ballX = 0.0;
  double _ballY = -1.0;
  int _score = 0;
  int _missed = 0;
  bool _gameStarted = false;
  bool _ballMoving = false;

  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  Timer? _ballTimer;
  Timer? _spawnTimer;

  final double _keeperSpeed = 15.0;
  final double _ballSpeed = 0.02;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initGyroscope();
  }

  void _initGyroscope() {
    _gyroSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
      if (_gameStarted && mounted) {
        setState(() {
          _keeperX += event.y * _keeperSpeed;
          _keeperX = _keeperX.clamp(-150.0, 150.0);
        });
      }
    });
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
      _missed = 0;
      _ballY = -1.0;
      _keeperX = 0.0;
    });

    _spawnTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_gameStarted && !_ballMoving) {
        _spawnBall();
      }
    });
  }

  void _spawnBall() {
    setState(() {
      _ballX = (_random.nextDouble() * 300) - 150;
      _ballY = -1.0;
      _ballMoving = true;
    });

    _ballTimer?.cancel();
    _ballTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted || !_gameStarted) {
        timer.cancel();
        return;
      }

      setState(() {
        _ballY += _ballSpeed;

        if (_ballY >= 0.85) {
          timer.cancel();
          _ballMoving = false;

          double distance = (_ballX - _keeperX).abs();
          if (distance < 50) {
            _score++;
            _showFeedback('SAVED! ⚽', Colors.green);
          } else {
            _missed++;
            _showFeedback('GOAL! 😢', Colors.red);
            if (_missed >= 5) {
              _endGame();
            }
          }
        }
      });
    });
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: color,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _endGame() {
    _ballTimer?.cancel();
    _spawnTimer?.cancel();

    setState(() {
      _gameStarted = false;
      _ballMoving = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[900]!, Colors.grey[800]!],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _score >= 10
                  ? Colors.amber
                  : _score >= 5
                  ? Colors.green
                  : Colors.red,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (_score >= 10
                            ? Colors.amber
                            : _score >= 5
                            ? Colors.green
                            : Colors.red)
                        .withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _score >= 10
                    ? '🏆'
                    : _score >= 5
                    ? '⭐'
                    : '💪',
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 10),
              const Text(
                'GAME OVER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.sports_score,
                          color: Colors.green,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Saved: ',
                          style: TextStyle(fontSize: 20, color: Colors.white70),
                        ),
                        Text(
                          _score.toString(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, color: Colors.red, size: 30),
                        const SizedBox(width: 10),
                        const Text(
                          'Missed: ',
                          style: TextStyle(fontSize: 20, color: Colors.white70),
                        ),
                        Text(
                          _missed.toString(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _score >= 10
                        ? [Colors.amber, Colors.orange]
                        : _score >= 5
                        ? [Colors.green, Colors.lightGreen]
                        : [Colors.red, Colors.redAccent],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  _score >= 10
                      ? '🥇 HEBAT! KIPER PREMIER LEAGUE!'
                      : _score >= 5
                      ? '⚽ BAGUS! KEEP PRACTICING!'
                      : '💪 COBA LAGI!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _startGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      label: const Text(
                        'Main Lagi',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.exit_to_app, color: Colors.white),
                      label: const Text(
                        'Keluar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloud(double size) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }

  Widget _buildScoreCard({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
    required Gradient gradient,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              Row(
                children: [
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gyroSubscription?.cancel();
    _ballTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⚽ Goalkeeper Challenge',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        elevation: 8,
        shadowColor: Colors.black54,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[900]!, Colors.blue[700]!, Colors.green[700]!],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Clouds decoration
            if (_gameStarted) ...[
              Positioned(top: 100, left: 20, child: _buildCloud(60)),
              Positioned(top: 150, right: 30, child: _buildCloud(80)),
              Positioned(top: 250, left: 100, child: _buildCloud(50)),
            ],

            // Score cards
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreCard(
                    icon: Icons.sports_score,
                    label: 'Saved',
                    value: _score,
                    color: Colors.green,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                    ),
                  ),
                  _buildScoreCard(
                    icon: Icons.close,
                    label: 'Missed',
                    value: _missed,
                    color: Colors.red,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC62828), Color(0xFFEF5350)],
                    ),
                    subtitle: '/5',
                  ),
                ],
              ),
            ),

            if (!_gameStarted)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.yellow, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellow.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Text('⚽', style: TextStyle(fontSize: 60)),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Goalkeeper Challenge',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 10,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_android,
                                  color: Colors.yellow,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Miringkan HP kiri-kanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'untuk menggerakkan kiper!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 10),
                            Divider(color: Colors.yellow, thickness: 2),
                            SizedBox(height: 10),
                            Text(
                              '🥅 Tangkap bola sebelum masuk gawang!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '⚠️ Game Over jika kebobolan 5 kali!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                          shadowColor: Colors.yellow,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                              size: 30,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'MULAI GAME',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_gameStarted)
              Positioned(
                left: size.width / 2 + _ballX - 25,
                top: size.height * 0.1 + (size.height * 0.7 * (_ballY + 1) / 2),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Colors.white, Colors.black87],
                      stops: [0.3, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('⚽', style: TextStyle(fontSize: 35)),
                  ),
                ),
              ),

            if (_gameStarted)
              Positioned(
                bottom: 50,
                left: size.width / 2 + _keeperX - 45,
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFF6F00),
                            Color(0xFFFF8F00),
                            Color(0xFFFFA726),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.6),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Text('🧤', style: TextStyle(fontSize: 55)),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '1',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.grey],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text(
                        'KIPER',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Goal post
            if (_gameStarted)
              Positioned(
                bottom: 130,
                left: size.width / 2 - 120,
                child: Container(
                  width: 240,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: CustomPaint(painter: NetPainter()),
                ),
              ),

            // Field lines
            if (_gameStarted)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.green[800]!, Colors.green[900]!],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Striped pattern
                      Row(
                        children: List.generate(
                          20,
                          (index) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: index % 2 == 0
                                    ? Colors.green[700]
                                    : Colors.green[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // White line
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(height: 4, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double spacing = 15;

    // Vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
