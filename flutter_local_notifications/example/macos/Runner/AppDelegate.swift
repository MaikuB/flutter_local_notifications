import Cocoa
import FlutterMacOS
import UserNotifications

@main
class AppDelegate: FlutterAppDelegate, UNUserNotificationCenterDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    if #available(macOS 10.14, *) {
      UNUserNotificationCenter.current().delegate = self
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  @available(macOS 10.14, *)
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    openSettingsFor notification: UNNotification?
  ) {
    if let window = NSApplication.shared.mainWindow,
       let controller = window.contentViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.example.flutter_local_notifications_example/settings",
        binaryMessenger: controller.engine.binaryMessenger)

      channel.invokeMethod("showNotificationSettings", arguments: nil)
    }
  }
}
