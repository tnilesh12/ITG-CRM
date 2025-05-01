import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nt_crm/config/app_config.dart';

// Windows FFI typedefs
typedef GetIdleTimeC = ffi.Uint32 Function();
typedef GetIdleTimeDart = int Function();

class IdleTimeProvider {
  static const MethodChannel _channel = MethodChannel('com.ntcrm/idle');

  static final ffi.DynamicLibrary? _windowsDll = Platform.isWindows
      ? ffi.DynamicLibrary.open("Idle-device.dll")
      : null;

  static final GetIdleTimeDart? _getIdleTimeWindows = Platform.isWindows
      ? _windowsDll!
          .lookup<ffi.NativeFunction<GetIdleTimeC>>("GetIdleTimeInSeconds")
          .asFunction()
      : null;

  static Future<int> getIdleTimeInSeconds() async {
    if (Platform.isWindows && _getIdleTimeWindows != null) {
      return _getIdleTimeWindows!();
    } else if (Platform.isMacOS) {
      try {
        final int seconds = await _channel.invokeMethod<int>('getIdleTime') ?? 0;
        return seconds;
      } catch (e) {
        return 0;
      }
    } else {
      return 0;
    }
  }
}

class IdleTracker {
  Timer? _poller;
  bool _hasFired10 = false;
  bool _hasFired15 = false;

  void start(
    BuildContext context,
    void Function(String) onEvent, {
    VoidCallback? onAutoStop,
  }) {
    _poller?.cancel();
    _poller = Timer.periodic(const Duration(seconds: 10), (_) async {
      final seconds = await IdleTimeProvider.getIdleTimeInSeconds();
      debugPrint("Idle: $seconds sec");

      if (seconds >= 900 && !_hasFired15) {
        _hasFired15 = true;
        _hasFired10 = true;
        onEvent("User idle for 15 minutes");
        final msg = await _stopTimerAndShowSnackbar(context);
        onEvent(msg);
        if (onAutoStop != null) {
          onAutoStop();
        }
      } else if (seconds >= 600 && !_hasFired10) {
        _hasFired10 = true;
        onEvent("User idle for 10 minutes");
      } else if (seconds < 600) {
        _hasFired10 = false;
        _hasFired15 = false;
      }
    });
  }

  void stop() {
    _poller?.cancel();
    _poller = null;
    _hasFired10 = false;
    _hasFired15 = false;
  }

  Future<String> _stopTimerAndShowSnackbar(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('userId');

      final response = await http.post(
        Uri.parse('${AppConfig.BASE_URL_API}api/v1/auto-stop-timer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"userId": currentUserId}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? "Task stopped successfully";
        _showSnackBar(context, message);
        return message;
      } else {
        // _showSnackBar(context, "Failed to auto-stop task (Status ${response.statusCode})");
        return "Error stopping task";
      }
    } catch (e) {
      debugPrint("--catch Response: ${e}");
      // _showSnackBar(context, "Error: $e");
      return "API call failed";
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 1),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
