import 'package:flutter/material.dart';
import 'package:nt_crm/config/app_config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocketManager {
  final String userId;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late IO.Socket socket;

  SocketManager({
    required this.userId,
    required this.flutterLocalNotificationsPlugin,
  });

  void connect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId); // Persist for reconnects

    debugPrint('-1----scoketurl ${AppConfig.BASE_URL_API}');
    socket = IO.io(
      AppConfig.BASE_URL_API,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setQuery({'userId': userId})
          .build(),
    );
    debugPrint('--1---socket ${socket}');

    debugPrint('--2---scoketurl ${AppConfig.BASE_URL_API}');
    debugPrint('--2---socket ${socket}');

    socket.onConnect((_) {
      debugPrint('---- Socket Connected as $userId');
    });

    socket.on('notification', (data) {
      debugPrint('---- Notification received: $data');
      _showLocalNotification(data);
    });

    socket.onDisconnect((_) => debugPrint('---- Socket Disconnected'));
    socket.onError((error) => debugPrint('---- Socket Error: $error'));
  }

  void disconnect() {
    socket.dispose();
  }
  
  void _showLocalNotification(dynamic data) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'Notifications',
      channelDescription: 'CRM Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails macDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      macOS: macDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      data['title'] ?? 'New Notification',
      data['message'] ?? '',
      platformDetails,
    );
  }
}
