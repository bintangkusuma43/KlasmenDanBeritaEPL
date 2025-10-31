import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/user_model.dart';
import 'services/time_location_service.dart';
import 'services/notification_service.dart';
import 'utils/session_utils.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_wrapper.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // INIT HIVE
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(UserModelAdapter());
      // Open boxes without generic param to avoid type-cast failures when
      // existing stored data doesn't match the current adapter shape.
      await Hive.openBox('userBox');
      await Hive.openBox('saranKesanBox');
    } catch (e, st) {
      debugPrint('Error initializing Hive: $e\n$st');
      // Jika Hive gagal, kita tetap jalankan app tanpa fitur local storage
    }

    // INIT SERVICES
    TimeLocationService().initializeTimezones();
    try {
      await NotificationService().initialize();
    } catch (e, st) {
      debugPrint('Notification init failed: $e\n$st');
    }

    final session = await checkSession();
    final bool isLoggedIn = session['isLoggedIn'] as bool? ?? false;

    runApp(MyApp(isLoggedIn: isLoggedIn));
  } catch (e) {
    debugPrint('Error initializing app: $e');
    // Fallback ke login screen jika terjadi error
    runApp(const MyApp(isLoggedIn: false));
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Klasemen Liga Inggris',
      theme: ThemeData.dark(),
      home: isLoggedIn ? const MainWrapper() : const LoginScreen(),
    );
  }
}
