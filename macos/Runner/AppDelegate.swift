import FlutterMacOS
import Cocoa

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    let registrar = controller.registrar(forPlugin: "IdleTimePlugin")
    IdleTimePlugin.register(with: registrar)
    super.applicationDidFinishLaunching(notification)
  }
}
