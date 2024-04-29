import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationManager() {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    // Initialize settings for Android and iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    // Initialize the plugin with the settings
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification({
    int id = 0,
    String title = 'Notification',
    String body = 'This is a notification',
  }) async {
    // Create a notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '10d28a0454cf',
      'Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    // Schedule the notification
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
