/// Configuración específica para Firebase Messaging en Web.
class FirebaseWebConfig {
  FirebaseWebConfig._();

  /// Clave pública VAPID generada en Firebase Console (Project Settings > Cloud Messaging).
  ///
  /// Reemplaza el valor por la clave real para que `getToken` pueda generar
  /// tokens válidos en plataformas web.
  static const String vapidKey = 'BPo0bPM3a-GCk4Qxr20hHbsyBUl7Rn3jkpNkkBDMB-zNUuRFiP13s';
}
