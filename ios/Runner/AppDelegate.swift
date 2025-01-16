import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
    guard let pluginRegistrar = self.registrar(forPlugin: "snow") else { return false }
      
    let factory = FLNativeSnowViewFactory(messenger: pluginRegistrar.messenger())
      
    pluginRegistrar.register(
      factory,
      withId: "com.case_ios_native_view/snow"
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
