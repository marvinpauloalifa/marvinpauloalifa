import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDL33Wh7Agj2qJ7SQcNb5OV2uKwXYq_JFc")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Precisamos da sua localização para mostrar farmácias próximas</string>
  <key>NSLocationAlwaysUsageDescription</key>
  <string>Precisamos da sua localização para mostrar farmácias próximas</string>

}

