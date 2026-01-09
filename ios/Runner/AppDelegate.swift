import Flutter
import UIKit


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "app.uptime/channel"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { call, result in
      if call.method == "uptimeMillis" {
        let seconds = ProcessInfo.processInfo.systemUptime
        let millis = Int(seconds * 1000.0)
        result(millis)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
