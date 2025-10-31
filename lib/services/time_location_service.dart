import 'package:geolocator/geolocator.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class TimeLocationService {
  // Initialize tz database once and cache commonly used locations
  bool _tzInitialized = false;
  final Map<String, tz.Location> _cachedLocations = {};

  void initializeTimezones() {
    if (!_tzInitialized) {
      tzdata.initializeTimeZones();
      _tzInitialized = true;
    }
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
    }

    try {
      // Menambahkan timeout untuk menghindari freeze
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      return null;
    }
  }

  String convertTimeToTargetZone(
    String londonDateTimeString,
    String targetTimeZone,
  ) {
    try {
      // Pastikan timezone data sudah diinisialisasi
      if (!_tzInitialized) initializeTimezones();

      // Parse dengan DateTime.parse dari UTC string lalu konversi menggunakan tz
      final utc = DateTime.parse(londonDateTimeString).toUtc();

      final londonLoc = _cachedLocations.putIfAbsent(
        'Europe/London',
        () => tz.getLocation('Europe/London'),
      );
      final targetLoc = _cachedLocations.putIfAbsent(
        targetTimeZone,
        () => tz.getLocation(targetTimeZone),
      );

      final londonTime = tz.TZDateTime.from(utc, londonLoc);
      final localTime = tz.TZDateTime.from(londonTime, targetLoc);

      final zoneName = targetTimeZone.split('/').last.replaceAll('_', ' ');
      return "${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')} ${zoneName.toUpperCase()}";
    } catch (e) {
      return "Waktu N/A";
    }
  }
}
