import Cocoa
import FlutterMacOS
import UserNotifications
import flutter_local_notifications

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}
