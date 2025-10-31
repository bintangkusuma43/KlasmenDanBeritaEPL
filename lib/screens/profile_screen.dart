import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../database/hive_service.dart';
import '../utils/session_utils.dart';
import 'auth/login_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _currentUser == null
            ? const Center(child: CircularProgressIndicator())
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
                                                if (path.startsWith('data:')) {
                                                  try {
                                                    final comma = path.indexOf(
                                                      ',',
                                                    );
                                                    final base64Part = path
                                                        .substring(comma + 1);
                                                    final bytes = base64Decode(
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
                          const SizedBox(height: 12),
                          Text(
                            _currentUser?.nama ?? 'Guest',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Email: ${_currentUser?.email ?? '-'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tim Jagoan: ${_currentUser?.favoriteTeam ?? '-'}',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            color: Colors.grey[850],
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: Colors.yellow,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.feedback,
                                        color: Colors.yellow,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Kesan & Saran',
                                        style: TextStyle(
                                          color: Colors.yellow,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _currentUser?.kesanSaran ??
                                        '- Belum ada keterangan -',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 160,
                            child: ElevatedButton(
                              onPressed: _logout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink[100],
                                foregroundColor: Colors.red[900],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Logout'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
