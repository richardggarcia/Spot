import 'web_push_notification_service_stub.dart'
    if (dart.library.html) 'web_push_notification_service_web.dart' as web_impl;

/// Fachada para gestionar Firebase Cloud Messaging en Web.
///
/// En plataformas no web, las operaciones son no-op.
class WebPushNotificationService {
  WebPushNotificationService._();

  static final WebPushNotificationService instance = WebPushNotificationService._();

  Future<void> initialize() => web_impl.initializeWebPushMessaging();

  Future<void> dispose() => web_impl.disposeWebPushMessaging();
}
