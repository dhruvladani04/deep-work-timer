import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(initSettings);
  }

  Future<void> requestPermissions() async {
    if (!kIsWeb && Platform.isAndroid) {
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'timer_channel',
      'Timer Notifications',
      channelDescription: 'Alerts for timer completion',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0, // ID (can be unique per notification if needed)
      title,
      body,
      notificationDetails,
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
