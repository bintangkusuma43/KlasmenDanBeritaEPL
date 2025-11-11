import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/match_model.dart';
import '../services/api_service.dart';
import '../services/time_location_service.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<MatchModel> _matches = [];
  String?
  _localTimezone; // Akan menyimpan zona waktu terdeteksi (misal: Asia/Makassar)
  late Position? _currentLocation;
  bool _isLoading = true;

  final TimeLocationService _timeService = TimeLocationService();
  final ApiService _apiService = ApiService();

  // Daftar zona waktu wajib (WIB, WITA, WIT, London)
  final Map<String, String> _targetTimeZones = {
    'LONDON (GMT)': 'Europe/London',
    'WIB': 'Asia/Jakarta',
    'WITA': 'Asia/Makassar',
    'WIT': 'Asia/Jayapura',
  };

  @override
  void initState() {
    super.initState();
    _loadMatchData();
  }

  Future<void> _loadMatchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Dapatkan Lokasi Pengguna (LBS Kriteria Wajib)
      // Run location detection in background without blocking
      _currentLocation = await _timeService.getCurrentLocation();

      // Tentukan zona waktu berdasarkan koordinat LBS
      if (_currentLocation != null) {
        // LOGIC SIMULASI DETEKSI KOORDINAT KE ZONA WAKTU (LBS)
        // Ini adalah simulasi: Di aplikasi nyata, Anda memerlukan API Geocoding
        double longitude = _currentLocation!.longitude;

        if (longitude >= 120.0) {
          _localTimezone = 'Asia/Jayapura'; // WIT
        } else if (longitude >= 113.0) {
          _localTimezone = 'Asia/Makassar'; // WITA
        } else {
          _localTimezone = 'Asia/Jakarta'; // WIB (Default)
        }
      } else {
        // Default jika LBS gagal mendapatkan lokasi
        _localTimezone = 'Asia/Jakarta';
      }

      // 2. Ambil Data Pertandingan (Data Statis 10 Match Mendatang)
      _matches = await _apiService.fetchStaticMatches();
    } catch (e) {
      debugPrint("Error loading match data: $e");
      // Set default values on error
      _localTimezone = 'Asia/Jakarta';
      _matches = await _apiService.fetchStaticMatches();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Fungsi untuk konversi waktu (tetap sama)
  String _getAllConvertedTimes(String kickoffUtc) {
    String output = "";

    // 1. Tambahkan Konversi Wajib (4 Zona Waktu)
    _targetTimeZones.forEach((name, zoneId) {
      final convertedTime = _timeService.convertTimeToTargetZone(
        kickoffUtc,
        zoneId,
      );
      output += "$name: $convertedTime\n";
    });

    // 2. Tambahkan Waktu Berdasarkan Koordinat LBS (Waktu Lokal Pengguna)
    if (_localTimezone != null && _currentLocation != null) {
      final detectedTime = _timeService.convertTimeToTargetZone(
        kickoffUtc,
        _localTimezone!,
      );
      output += "\n-------------------------------------\n";
      output += "Waktu Dideteksi Berdasarkan Koordinat:\n";
      output += "Zona (${_localTimezone!.split('/').last}): $detectedTime";
    } else {
      output += "\n-------------------------------------\n";
      output += "Lokasi GPS tidak terdeteksi, menggunakan WIB default.";
    }

    return output;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jadwal Pertandingan',
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
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Memuat jadwal pertandingan...',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 12,
                  bottom: 100,
                ),
                itemCount: _matches.length,
                itemBuilder: (context, index) {
                  final match = _matches[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey[850]!, Colors.grey[900]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  match.date,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.yellow.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Text(
                                    match.homeTeam,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
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
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.yellow.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'VS',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    match.awayTeam,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue[900]!.withOpacity(0.3),
                                  Colors.purple[900]!.withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 18,
                                      color: Colors.blue[300],
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Detail Waktu Konversi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getAllConvertedTimes(match.time),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      height: 1.5,
                                    ),
                                  ),
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
    );
  }
}
