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
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          '🏆 GAME OVER 🏆',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skor Akhir: $_score',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Kebobolan: $_missed',
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Text(
              _score >= 10
                  ? 'Hebat! Kiper Premier League! 🥇'
                  : _score >= 5
                  ? 'Bagus! Keep practicing! ⚽'
                  : 'Coba lagi! 💪',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text(
              'Main Lagi',
              style: TextStyle(color: Colors.yellow, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
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
        title: const Text('⚽ Goalkeeper Challenge'),
        backgroundColor: Colors.green[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[900]!, Colors.green[700]!],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Saved: $_score',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Missed: $_missed/5',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (!_gameStarted)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sports_soccer,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Goalkeeper Challenge',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Miringkan HP kiri-kanan untuk menggerakkan kiper!\n\nTangkap bola sebelum masuk gawang!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 40),
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
                      ),
                      child: const Text(
                        'MULAI GAME',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_gameStarted)
              Positioned(
                left: size.width / 2 + _ballX - 20,
                top: size.height * 0.1 + (size.height * 0.7 * (_ballY + 1) / 2),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white, Colors.black87],
                    ),
                  ),
                  child: const Center(
                    child: Text('⚽', style: TextStyle(fontSize: 30)),
                  ),
                ),
              ),

            if (_gameStarted)
              Positioned(
                bottom: 50,
                left: size.width / 2 + _keeperX - 40,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Center(
                        child: Text('🧤', style: TextStyle(fontSize: 50)),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'KIPER',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_gameStarted)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[900]!, Colors.green[600]!],
                    ),
                  ),
                  child: Row(
                    children: List.generate(
                      10,
                      (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          color: index % 2 == 0
                              ? Colors.green[800]
                              : Colors.green[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
