import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    configureFirebaseIfNeeded()

    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self

    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    super.application(
      application,
      didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
    )

    Messaging.messaging().apnsToken = deviceToken
    Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    NSLog("❌ No se pudo registrar en APNs: \(error.localizedDescription)")
  }

  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    Messaging.messaging().appDidReceiveMessage(userInfo)
    super.application(
      application,
      didReceiveRemoteNotification: userInfo,
      fetchCompletionHandler: completionHandler
    )
  }

  private func configureFirebaseIfNeeded() {
    guard FirebaseApp.app() == nil else { return }

    if
      let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
      let options = FirebaseOptions(contentsOfFile: filePath)
    {
      FirebaseApp.configure(options: options)
      NSLog("✅ Firebase configurado desde GoogleService-Info.plist")
    } else {
      NSLog("⚠️ Firebase no se configuró: falta GoogleService-Info.plist válido")
    }
  }

  // MARK: - MessagingDelegate

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let token = fcmToken else {
      NSLog("⚠️ FCM sin token recibido (nil)")
      return
    }

    NotificationCenter.default.post(
      name: Notification.Name("spot_fcm_token_refresh"),
      object: nil,
      userInfo: ["token": token]
    )

    NSLog("✅ Token FCM actualizado: \(token)")
  }

  // MARK: - UNUserNotificationCenterDelegate

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.sound, .alert, .badge])
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    Messaging.messaging().appDidReceiveMessage(response.notification.request.content.userInfo)
    NotificationCenter.default.post(
      name: Notification.Name("spot_notification_tap"),
      object: nil,
      userInfo: response.notification.request.content.userInfo
    )
    completionHandler()
  }
}
