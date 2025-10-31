import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../database/hive_service.dart';
import '../../models/user_model.dart';
import '../../utils/encryption_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  final HiveService _hiveService = HiveService();

  // EPL Teams 2023/2024
  final List<String> _eplTeams = [
    'Arsenal',
    'Aston Villa',
    'Bournemouth',
    'Brentford',
    'Brighton',
    'Burnley',
    'Chelsea',
    'Crystal Palace',
    'Everton',
    'Fulham',
    'Liverpool',
    'Luton Town',
    'Manchester City',
    'Manchester United',
    'Newcastle United',
    'Nottingham Forest',
    'Sheffield United',
    'Tottenham Hotspur',
    'West Ham United',
    'Wolves',
  ];

  String? _selectedTeam;
  File? _profilePhotoFile;
  Uint8List? _profilePhotoBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _profilePhotoBytes = bytes;
          _profilePhotoFile = null;
        });
      } else {
        setState(() {
          _profilePhotoFile = File(pickedFile.path);
          _profilePhotoBytes = null;
        });
      }
    }
  }

  Future<String?> _saveImageToLocal() async {
    try {
      // On web, we cannot write to the device filesystem — store as data URI
      if (kIsWeb) {
        if (_profilePhotoBytes == null) return null;
        final base64Data = base64Encode(_profilePhotoBytes!);
        return 'data:image/jpeg;base64,$base64Data';
      }

      if (_profilePhotoFile == null) return null;

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await _profilePhotoFile!.copy(
        '${directory.path}/$fileName',
      );
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String hashedPassword = hashPassword(_passwordController.text);
      if (_selectedTeam == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tim jagoan terlebih dahulu')),
        );
        return;
      }
      String? savedImagePath;
      if (_profilePhotoFile != null) {
        savedImagePath = await _saveImageToLocal();
        if (savedImagePath == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan foto profil')),
          );
          return;
        }
      }
      final newUser = UserModel(
        id: null,
        nama: _nameController.text,
        email: email,
        passwordHash: hashedPassword,
        favoriteTeam: _selectedTeam!,
        profilePhotoUrl: savedImagePath,
        kesanSaran: _feedbackController.text.isNotEmpty
            ? _feedbackController.text
            : null,
      );
      try {
        debugPrint('Register: Checking if user exists for email: $email');
        if (_hiveService.getUserByEmail(newUser.email) != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi Gagal. Email sudah terdaftar.'),
            ),
          );
          return;
        }
        debugPrint('Register: Inserting user: \\${newUser.toJson()}');
        await _hiveService
            .insertUser(newUser)
            .timeout(const Duration(seconds: 10));
        debugPrint('Register: User inserted. Checking again...');
        if (_hiveService.getUserByEmail(newUser.email) != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi Berhasil! Silakan Login.'),
            ),
          );
          Navigator.pop(context); // Kembali ke LoginScreen
        } else {
          debugPrint('Register: User not found after insert!');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registrasi gagal. User tidak ditemukan setelah insert.',
              ),
            ),
          );
        }
      } catch (e, st) {
        debugPrint('Register: Error during registration: $e\n$st');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error DB Hive: Gagal menyimpan data user.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Pengguna Baru')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nama
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 15),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v!.isEmpty || !v.contains('@') ? 'Email tidak valid' : null,
              ),
              const SizedBox(height: 15),

              // Password (Enkripsi)
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (min. 6 karakter)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (v) =>
                    v!.length < 6 ? 'Password minimal 6 karakter' : null,
              ),
              const SizedBox(height: 15),

              // Tim Jagoan - Dropdown EPL Teams
              DropdownButtonFormField<String>(
                initialValue: _selectedTeam,
                decoration: const InputDecoration(
                  labelText: 'Tim Jagoan Liga Inggris',
                  border: OutlineInputBorder(),
                ),
                items: _eplTeams.map((String team) {
                  return DropdownMenuItem<String>(
                    value: team,
                    child: Text(team),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTeam = newValue;
                  });
                },
                validator: (v) => v == null ? 'Pilih tim jagoan' : null,
              ),
              const SizedBox(height: 15),

              // Profile Photo Picker
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (_profilePhotoBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _profilePhotoBytes!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (_profilePhotoFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _profilePhotoFile!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_camera),
                      label: Text(
                        _profilePhotoFile == null
                            ? 'Pilih Foto Profil'
                            : 'Ganti Foto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Kesan dan Saran (textarea)
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText:
                      'Kesan & Saran untuk Mata Kuliah Pemrograman Aplikasi Mobile',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // Tombol Daftar
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'DAFTAR AKUN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
