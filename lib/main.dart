import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nt_crm/view/home_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final WindowsInitializationSettings initializationSettingsWindows =
      WindowsInitializationSettings(
          appName: 'CRM',
          appUserModelId: "com.example.ntCrm",
          guid: '7b577a1c-26a3-4e1b-b552-1c2dc40945b3');

  final DarwinInitializationSettings darwinInitializationSettings = DarwinInitializationSettings();

  var initializationSettings = InitializationSettings(
    windows: initializationSettingsWindows,
    macOS: darwinInitializationSettings
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  final macosPlugin = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
  final granted = macosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

  runApp(MyApp(
    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
  ));
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const MyApp({required this.flutterLocalNotificationsPlugin});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NT',
        home: HomeScreen(
            flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin));
  }
}
