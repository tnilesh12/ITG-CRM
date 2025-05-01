import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nt_crm/config/app_config.dart';
import 'package:nt_crm/cpilot/customize_widget_view.dart';

class HomeScreen extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  const HomeScreen({required this.flutterLocalNotificationsPlugin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(title: const Text('NT')),
        body: Container(
        alignment: Alignment.center,
        child: CustomizeWidgetView(
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
          url: AppConfig.BASE_URL,
        ),
    ));
  }
}
