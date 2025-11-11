import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../database/hive_service.dart';
import '../utils/session_utils.dart';
import 'auth/login_screen.dart';
import 'goalkeeper_game_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final HiveService _hiveService = HiveService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final session = await checkSession();
    final int? userId = session['userId'] as int?;
    if (userId != null) {
      final user = _hiveService.getUserById(userId);
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    }
  }

  Future<void> _logout() async {
    await clearSession();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _showKesanSaranDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.yellow, width: 2),
          ),
          title: const Row(
            children: [
              Icon(Icons.feedback, color: Colors.yellow),
              SizedBox(width: 8),
              Text(
                'Kesan & Saran',
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '📝 Kesan:',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Terima kasih Pak Bagus, berkat tugas dari bapak saya semakin rajin untuk berdoa dan beribadah. Izinkan saya mengucapkan kata-kata keramat "Segampang itu"',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '💡 Saran:',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Saran saya ganti kata-kata "segampang itu" menjadi "semumet itu". Maaf jika aplikasi saya tidak bagus, karna saya Tatang bukan Bagus',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Tutup',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[900]!, Colors.black],
          ),
        ),
        child: SafeArea(
          child: _currentUser == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.yellow,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Memuat profil...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 32.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.yellow,
                                    Colors.pink,
                                    Colors.purple,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.2),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 66,
                                    backgroundColor: Colors.grey[200],
                                    child: _currentUser?.profilePhotoUrl != null
                                        ? ClipOval(
                                            child: Builder(
                                              builder: (context) {
                                                final path = _currentUser!
                                                    .profilePhotoUrl!;
                                                try {
                                                  if (path.startsWith('http')) {
                                                    return Image.network(
                                                      path,
                                                      width: 120,
                                                      height: 120,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => const Icon(
                                                            Icons.person,
                                                            size: 60,
                                                          ),
                                                    );
                                                  }
                                                  if (path.startsWith(
                                                    'data:',
                                                  )) {
                                                    try {
                                                      final comma = path
                                                          .indexOf(',');
                                                      final base64Part = path
                                                          .substring(comma + 1);
                                                      final bytes =
                                                          base64Decode(
                                                            base64Part,
                                                          );
                                                      return Image.memory(
                                                        bytes,
                                                        width: 120,
                                                        height: 120,
                                                        fit: BoxFit.cover,
                                                      );
                                                    } catch (_) {}
                                                  }
                                                  if (!kIsWeb) {
                                                    final file = File(path);
                                                    if (file.existsSync()) {
                                                      return Image.file(
                                                        file,
                                                        width: 120,
                                                        height: 120,
                                                        fit: BoxFit.cover,
                                                      );
                                                    }
                                                  }
                                                } catch (_) {}
                                                return const Icon(
                                                  Icons.person,
                                                  size: 60,
                                                );
                                              },
                                            ),
                                          )
                                        : const Icon(Icons.person, size: 60),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _currentUser?.nama ?? 'Guest',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[850]!,
                                    Colors.grey[900]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.email,
                                        color: Colors.yellow,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _currentUser?.email ?? '-',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFD700),
                                          Color(0xFFFFA500),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.yellow.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.shield,
                                          color: Colors.black,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _currentUser?.favoriteTeam ?? '-',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  // TOMBOL GAME KIPER - Hijau
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      // WARNA TOMBOL GAME: Gradient hijau muda ke terang
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF00C853), // Hijau tua
                                          Color(0xFF00E676), // Hijau terang
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          // WARNA SHADOW TOMBOL GAME: Hijau glow
                                          color: Colors.green.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const GoalkeeperGameScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        // WARNA TEXT & ICON TOMBOL GAME: Putih
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.sports_soccer,
                                        size: 24,
                                      ),
                                      label: const Text(
                                        'Main Game Kiper! ⚽',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  // TOMBOL KESAN & SARAN - Kuning
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      // WARNA TOMBOL KESAN & SARAN: Gradient kuning ke oranye
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFD700), // Kuning emas
                                          Color(0xFFFFA500), // Oranye
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          // WARNA SHADOW TOMBOL: Kuning glow
                                          color: Colors.yellow.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _showKesanSaranDialog(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        // WARNA TEXT & ICON TOMBOL: Hitam
                                        foregroundColor: Colors.black,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.feedback,
                                        size: 24,
                                      ),
                                      label: const Text(
                                        'Lihat Kesan & Saran',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            // TOMBOL LOGOUT - Merah
                            Container(
                              decoration: BoxDecoration(
                                // WARNA TOMBOL LOGOUT: Gradient merah terang ke gelap
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF1744), // Merah terang
                                    Color(0xFFD50000), // Merah gelap
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    // WARNA SHADOW LOGOUT: Merah glow
                                    color: Colors.red.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _logout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  // WARNA TEXT LOGOUT: Putih
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 32,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
