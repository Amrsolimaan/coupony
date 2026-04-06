import Flutter
import UIKit
import GoogleMaps
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase
    FirebaseApp.configure()
    
    // Google Maps API Key
    // KEY IS MANAGED VIA ENVIRONMENT — do not hardcode here.
    // Value flows: Local.xcconfig (MAPS_API_KEY_IOS) → Info.plist (MapsApiKey) → Bundle.main
    // For CI/CD: set MAPS_API_KEY_IOS as a User-Defined build setting in Xcode
    // or via: xcodebuild OTHER_SWIFT_FLAGS="$(inherited) -DMAPS_API_KEY_IOS=..."
    // ⚠️  Removed hardcoded key: GMSServices.provideAPIKey("AIzaSyDAS...qAE")
    let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "MapsApiKey") as? String ?? ""
    GMSServices.provideAPIKey(mapsApiKey)
    
    // Register for remote notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle remote notifications
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }
}
