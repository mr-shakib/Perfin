import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // TODO: Register LeapBridgePlugin once the LEAP SDK is installed:
    //   1. Open ios/Runner.xcworkspace in Xcode.
    //   2. Drag ios/Runner/LeapBridgePlugin.swift into the Runner target.
    //   3. Add the LEAP Swift Package (https://github.com/liquid-ai/leap-swift).
    //   4. Uncomment the line below:
    // LeapBridgePlugin.register(with: engineBridge.pluginRegistry.registrar(forPlugin: "LeapBridgePlugin")!)
  }
}
