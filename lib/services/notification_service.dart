import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return; // Prevent double initialization

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Pengaturan iOS minimal
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      _isInitialized = true;
    } catch (e) {
      // Silently fail if notification initialization fails
      _isInitialized = false;
    }
  }

  // Menampilkan Notifikasi (Kriteria Wajib: Mengingatkan berita/pertandingan)
  Future<void> showNotification(int id, String title, String body) async {
    if (!_isInitialized) {
      // If not initialized, skip notification
      return;
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'berita_channel_id',
            'Berita Liga Inggris',
            channelDescription: 'Notifikasi untuk update berita terbaru',
            importance: Importance.max,
            priority: Priority.high,
          );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
      );
    } catch (e) {
      // Silently fail if notification fails
    }
  }
}
