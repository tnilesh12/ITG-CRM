import Cocoa
import FlutterMacOS
import IOKit

public class IdleTimePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.ntcrm/idle", binaryMessenger: registrar.messenger)
    let instance = IdleTimePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getIdleTime" {
      let idleTimeSec = self.getIdleTimeInSeconds()
      result(idleTimeSec)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func getIdleTimeInSeconds() -> Int {
    // var iterator: io_iterator_t = 0
    let matching = IOServiceMatching("IOHIDSystem")

    if let matching = matching {
      let entry = IOServiceGetMatchingService(kIOMainPortDefault, matching)
      if entry != 0 {
        var unmanagedObject: Unmanaged<AnyObject>?
        unmanagedObject = IORegistryEntryCreateCFProperty(entry, "HIDIdleTime" as CFString, kCFAllocatorDefault, 0)

        IOObjectRelease(entry)

        if let obj = unmanagedObject?.takeRetainedValue(), let number = obj as? NSNumber {
          let nanoseconds = number.int64Value
          return Int(nanoseconds / 1_000_000_000)
        }
      }
    }
    return 0
  }
}
