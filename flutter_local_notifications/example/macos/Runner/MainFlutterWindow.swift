import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController.init()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        
        let channel = FlutterMethodChannel(name: "dexterx.dev/flutter_local_notifications_example",
                                                  binaryMessenger: flutterViewController.engine.binaryMessenger)
        channel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          if ("getTimeZoneName" == call.method) {
            result(TimeZone.current.identifier)
          }
        })
        RegisterGeneratedPlugins(registry: flutterViewController)
        
        super.awakeFromNib()
    }
}
