import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/match_model.dart';
import '../services/api_service.dart';
import '../services/time_location_service.dart';

class MatchesScreen extends StatefulWidget {
  // Property isNextMatch dihapus sesuai finalisasi proyek
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

      // FIX UTAMA: Tentukan zona waktu berdasarkan koordinat LBS
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
        title: const Text('Jadwal Pertandingan (10 Match Mendatang)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(match.homeTeam),
                            const Text(
                              'vs',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow,
                              ),
                            ),
                            Text(match.awayTeam),
                          ],
                        ),
                        const Divider(height: 20),

                        Text(
                          'Detail Waktu Konversi:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[300],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _getAllConvertedTimes(match.time),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
