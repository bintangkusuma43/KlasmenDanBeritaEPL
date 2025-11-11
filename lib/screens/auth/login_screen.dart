import 'package:flutter/material.dart';
import '../../database/hive_service.dart';
import '../../utils/encryption_utils.dart';
import '../../utils/session_utils.dart';
import '../main_wrapper.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final HiveService _hiveService = HiveService();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final user = _hiveService.getUserByEmail(_emailController.text);

      if (user != null) {
        final String hashedInput = hashPassword(_passwordController.text);

        if (hashedInput == user.passwordHash) {
          // Sandi cocok (Login Berhasil!)

          // Simpan Session: Mengabaikan isAdmin karena sudah tidak ada
          if (user.id != null) {
            await saveSession(user.id!, false); // Set isAdmin = false
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Login Berhasil!')));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainWrapper()),
            );
          }
          return;
        }
      }

      // Jika email tidak ditemukan atau password salah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email atau Password salah.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[900]!, Colors.black, Colors.grey[900]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO ICON - Lingkaran dengan gradient kuning-oranye
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        // WARNA GRADIENT LOGO: Kuning ke Oranye
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFD700),
                            Color(0xFFFFA500),
                          ], // Kuning -> Oranye
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            // WARNA SHADOW LOGO: Kuning dengan transparansi
                            color: Colors.yellow.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sports_soccer,
                        size: 80,
                        // WARNA ICON BOLA: Hitam
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // JUDUL APLIKASI
                    const Text(
                      'Premier League',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        // WARNA JUDUL: Putih
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // SUBTITLE
                    const Text(
                      'Login to continue',
                      // WARNA SUBTITLE: Putih dengan opacity 60%
                      style: TextStyle(fontSize: 16, color: Colors.white60),
                    ),
                    const SizedBox(height: 50),
                    // CONTAINER FORM LOGIN
                    Container(
                      decoration: BoxDecoration(
                        // WARNA BACKGROUND FORM: Gradient abu gelap
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[850]!,
                            Colors.grey[900]!,
                          ], // Abu tua
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            // WARNA SHADOW FORM: Hitam dengan transparansi
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // INPUT EMAIL
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(
                                // WARNA LABEL EMAIL: Putih 70%
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(
                                Icons.email,
                                // WARNA ICON EMAIL: Kuning
                                color: Colors.yellow,
                              ),
                              filled: true,
                              // WARNA BACKGROUND INPUT EMAIL: Hitam dengan transparansi
                              fillColor: Colors.black.withValues(alpha: 0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  // WARNA BORDER EMAIL (normal): Putih transparan
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  // WARNA BORDER EMAIL (focus): Kuning
                                  color: Colors.yellow,
                                  width: 2,
                                ),
                              ),
                            ),
                            // WARNA TEXT EMAIL: Putih
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          // INPUT PASSWORD
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(
                                // WARNA LABEL PASSWORD: Putih 70%
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                                // WARNA ICON PASSWORD: Kuning
                                color: Colors.yellow,
                              ),
                              filled: true,
                              // WARNA BACKGROUND INPUT PASSWORD: Hitam dengan transparansi
                              fillColor: Colors.black.withValues(alpha: 0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  // WARNA BORDER PASSWORD (normal): Putih transparan
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  // WARNA BORDER PASSWORD (focus): Kuning
                                  color: Colors.yellow,
                                  width: 2,
                                ),
                              ),
                            ),
                            // WARNA TEXT PASSWORD: Putih
                            style: const TextStyle(color: Colors.white),
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // TOMBOL LOGIN - INI YANG SERING DIMINTA UBAH WARNANYA!
                    Container(
                      decoration: BoxDecoration(
                        // WARNA GRADIENT TOMBOL LOGIN: Kuning ke Oranye
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFD700),
                            Color(0xFFFFA500),
                          ], // Kuning -> Oranye
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            // WARNA SHADOW TOMBOL: Kuning dengan glow
                            color: Colors.yellow.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            // WARNA TEXT TOMBOL LOGIN: Hitam
                            color: Colors.black,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // TEXT LINK KE REGISTER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Belum punya akun? ",
                          // WARNA TEXT BIASA: Putih 70%
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          ),
                          child: const Text(
                            'Daftar di sini',
                            style: TextStyle(
                              // WARNA LINK REGISTER: Kuning
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
