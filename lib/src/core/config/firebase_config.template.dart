// Plantilla de configuración Firebase
// Copia este archivo a firebase_config.dart y completa con tus credenciales reales
// 
// IMPORTANTE: firebase_config.dart debe estar en .gitignore

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuración Firebase para todos los entornos
/// 
/// Para configurar:
/// 1. Copia este archivo a firebase_config.dart
/// 2. Reemplaza los valores XXX con tus credenciales reales de Firebase Console
/// 3. Nunca hagas commit del archivo firebase_config.dart
class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'FirebaseConfig no configurado para Windows',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'FirebaseConfig no configurado para Linux',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'FirebaseConfig no configurado para Fuchsia',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'XXX-REEMPLAZA-CON-TU-WEB-API-KEY-XXX',
    appId: 'XXX-REEMPLAZA-CON-TU-WEB-APP-ID-XXX',
    messagingSenderId: 'XXX-REEMPLAZA-CON-TU-SENDER-ID-XXX',
    projectId: 'tu-proyecto-firebase',
    authDomain: 'tu-proyecto-firebase.firebaseapp.com',
    storageBucket: 'tu-proyecto-firebase.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'XXX-REEMPLAZA-CON-TU-ANDROID-API-KEY-XXX',
    appId: 'XXX-REEMPLAZA-CON-TU-ANDROID-APP-ID-XXX',
    messagingSenderId: 'XXX-REEMPLAZA-CON-TU-SENDER-ID-XXX',
    projectId: 'tu-proyecto-firebase',
    storageBucket: 'tu-proyecto-firebase.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'XXX-REEMPLAZA-CON-TU-IOS-API-KEY-XXX',
    appId: 'XXX-REEMPLAZA-CON-TU-IOS-APP-ID-XXX',
    messagingSenderId: 'XXX-REEMPLAZA-CON-TU-SENDER-ID-XXX',
    projectId: 'tu-proyecto-firebase',
    storageBucket: 'tu-proyecto-firebase.appspot.com',
    iosBundleId: 'com.spottrading.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'XXX-REEMPLAZA-CON-TU-MACOS-API-KEY-XXX',
    appId: 'XXX-REEMPLAZA-CON-TU-MACOS-APP-ID-XXX',
    messagingSenderId: 'XXX-REEMPLAZA-CON-TU-SENDER-ID-XXX',
    projectId: 'tu-proyecto-firebase',
    storageBucket: 'tu-proyecto-firebase.appspot.com',
    iosBundleId: 'com.spottrading.app',
  );
}