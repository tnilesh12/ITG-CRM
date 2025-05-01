import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nt_crm/idle_tracker/idle_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../socket/SocketManager.dart';

SocketManager? socketManager;

class CustomizeWidgetView extends StatefulWidget {
  final String url;
  final Function(String, dynamic)? clickEvent;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const CustomizeWidgetView({
    required this.url,
    this.clickEvent,
    required this.flutterLocalNotificationsPlugin,
    super.key,
  });

  @override
  State<CustomizeWidgetView> createState() => _CustomizeWidgetViewState();
}

class _CustomizeWidgetViewState extends State<CustomizeWidgetView> {
  late InAppWebViewController _webViewController;
  bool isLoading = true;
  final IdleTracker _tracker = IdleTracker();

  @override
  void initState() {
    super.initState();
    _tryReconnectSocket();
    _tracker.start(
      context,
      (msg) => debugPrint("IdleTracker: $msg"),
      onAutoStop: _maybeReloadWebview,
    );
  }

  void _maybeReloadWebview() {
    _webViewController.getUrl().then((uri) {
      if (uri != null && uri.toString().contains("/dashboard/tasks/projects")) {
        debugPrint("Reloading task page due to inactivity...");
        _webViewController.reload();
      }
    });
  }

  void _tryReconnectSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('userId');

    if (currentUserId != null) {
      debugPrint("---- Reconnecting socket for userId: $currentUserId");
      socketManager = SocketManager(
        userId: currentUserId,
        flutterLocalNotificationsPlugin: widget.flutterLocalNotificationsPlugin,
      );
      socketManager!.connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          if (isLoading) const Center(child: CircularProgressIndicator()),
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              useOnDownloadStart: true,
              javaScriptCanOpenWindowsAutomatically: true,
              supportMultipleWindows: true, // Required for popups
              cacheEnabled: false,
              javaScriptEnabled: true,
              clearCache: false,
              clearSessionCache: false,
            ),
            initialUrlRequest: URLRequest(
              url: WebUri(widget.url),
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;

              controller.addJavaScriptHandler(
                handlerName: "onLoginSuccess",
                callback: (args) {
                  debugPrint("----onLoginSuccess-----Received JS args: $args");
                  final userId = args[0]['userId']!;
                  debugPrint("--Logged in as userId: $userId");

                  socketManager = SocketManager(
                    userId: userId,
                    flutterLocalNotificationsPlugin:
                        widget.flutterLocalNotificationsPlugin,
                  );
                  socketManager!.connect();
                },
              );

              controller.addJavaScriptHandler(
                handlerName: "onLogout",
                callback: (args) async {
                  debugPrint("--Logout triggered from JS");
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('userId');
                  socketManager?.disconnect();
                },
              );
},
            onLoadStart: (controller, url) {
              setState(() => isLoading = true);
            },
            onLoadStop: (controller, url) {
              if (isLoading) {
                setState(() => isLoading = false);
              }
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                setState(() => isLoading = false);
              }
            },
            onConsoleMessage: (controller, msg) {
              debugPrint("---[Console] ${msg.message}");
            },
            onReceivedHttpError: (controller, url, error) {
              debugPrint("---HTTP error: $error");
              setState(() => isLoading = false);
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED,
              );
            },
          ),
        ],
      ),
    );
  }
}
