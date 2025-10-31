import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveSession(int userId, bool isAdmin) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  await prefs.setInt('userId', userId);
  await prefs.setBool('isAdmin', isAdmin);
}

Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

Future<Map<String, dynamic>> checkSession() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'isLoggedIn': prefs.getBool('isLoggedIn') ?? false,
    'userId': prefs.getInt('userId'),
    'isAdmin': prefs.getBool('isAdmin') ?? false,
  };
}