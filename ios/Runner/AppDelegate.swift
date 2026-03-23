import UIKit
import Flutter
import GoogleMaps
import FirebaseCore
import Firebase
import FirebaseMessaging
import FBSDKCoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyDj8C1VcZWPlnRrHMc_2VjMLVZ3HmVxdWw")
    GeneratedPluginRegistrant.register(with: self)
    ApplicationDelegate.shared.application(
                application,
                didFinishLaunchingWithOptions: launchOptions
            )

        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "facebook_app_events", binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { (call, result) in
            if call.method == "logEvent" {
                guard let args = call.arguments as? [String: Any],
                      let eventName = args["eventName"] as? String,
                      let parameters = args["parameters"] as? [String: Any] else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments passed", details: nil))
                    return
                }

                // Convert [String: Any] to [AppEvents.ParameterName: Any]
                let convertedParameters = parameters.reduce(into: [AppEvents.ParameterName: Any]()) { (dict, pair) in
                    dict[AppEvents.ParameterName(pair.key)] = pair.value
                }

                // Use AppEvents.shared to call logEvent on the shared instance
                AppEvents.shared.logEvent(AppEvents.Name(rawValue: eventName), parameters: convertedParameters)
                result(nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func application(_ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

          Messaging.messaging().apnsToken = deviceToken
          print("Token: \(deviceToken)")
          super.application(application,
          didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
      }
}