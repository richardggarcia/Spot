# 🐛 PROBLEMA: Pantalla Blanca en SPOT

**Fecha:** 24 de Octubre de 2025  
**App:** spot (Flutter)  
**Estado:** Compila correctamente pero se queda en pantalla blanca al abrir

---

## 📊 **CONTEXTO:**

### **Lo que funciona:**
- ✅ App compila sin errores desde Xcode y terminal
- ✅ Build exitoso: `✓ Built build/ios/iphoneos/Runner.app`
- ✅ Se instala en el iPhone "Ricdev" (ID: 00008110-0008145A36B9401E)
- ✅ App se abre (no crashea)

### **El problema:**
- ❌ Pantalla se queda en BLANCO
- ❌ No muestra contenido
- ❌ No hay errores visibles en consola

---

## 🔍 **DIAGNÓSTICO:**

### **1. Firebase está deshabilitado (configuración dummy)**

**Archivo:** `lib/src/core/config/firebase_config.dart`

```dart
// Firebase está deshabilitado temporalmente debido a incompatibilidad con Xcode 26.x
// Este archivo proporciona una configuración dummy para evitar errores de compilación

class FirebaseConfig {
  static dynamic get currentPlatform {
    // Devuelve configuración dummy
    return _DummyFirebaseOptions(...)
  }
}
```

**PERO** el código en `main.dart` SÍ intenta inicializar Firebase:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚠️ Intenta inicializar con config dummy
  await Firebase.initializeApp(
    options: FirebaseConfig.currentPlatform,
  );

  // ⚠️ Registra handlers que no funcionarán
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  await ServiceLocator.setup();
  
  // ⚠️ Intenta inicializar notificaciones
  await NotificationService.initialize();
  
  // ⚠️ Test de notificaciones (puede fallar silenciosamente)
  Future.delayed(const Duration(seconds: 3), () async {
    await _testNotificationSystem();
  });

  runApp(SpotTradingApp(themeManager: themeManager));
}
```

---

### **2. Posibles causas de la pantalla blanca:**

#### **CAUSA A: Firebase falla silenciosamente** ⭐⭐⭐⭐
```dart
await Firebase.initializeApp(options: DummyConfig)
// ↓ Puede fallar pero no lanza excepción
// ↓ App continúa pero Firebase no funciona
// ↓ Otros servicios dependen de Firebase
// ↓ Pantalla blanca
```

#### **CAUSA B: ServiceLocator no inicializa BLoC correctamente** ⭐⭐⭐
```dart
await ServiceLocator.setup()
// ↓ Si falla aquí, no hay CryptoBloc
// ↓ BlocProvider intenta obtener BLoC inexistente
// ↓ Pantalla blanca
```

#### **CAUSA C: NotificationService.initialize() se cuelga** ⭐⭐⭐
```dart
await NotificationService.initialize()
// ↓ Si espera respuesta de Firebase que nunca llega
// ↓ Se queda esperando indefinidamente
// ↓ runApp() nunca se ejecuta
// ↓ Pantalla blanca
```

#### **CAUSA D: CryptoBloc no carga datos iniciales** ⭐⭐
```dart
ServiceLocator.get<CryptoBloc>()..add(GetAllCryptosWithMetrics())
// ↓ Si este evento falla
// ↓ No hay datos para mostrar
// ↓ Pantalla blanca (esperando datos que nunca llegan)
```

---

## 🎯 **SOLUCIONES PROPUESTAS:**

### **SOLUCIÓN 1: Deshabilitar Firebase completamente** ⭐⭐⭐⭐⭐ (RECOMENDADO)

**Modificar:** `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ❌ COMENTAR TODO FIREBASE
  // await Firebase.initializeApp(
  //   options: FirebaseConfig.currentPlatform,
  // );
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await ServiceLocator.setup();

  final themeManager = ThemeManager();
  await themeManager.loadThemePreference();

  // ❌ COMENTAR NOTIFICACIONES
  // await NotificationService.initialize();
  // Future.delayed(const Duration(seconds: 3), () async {
  //   await _testNotificationSystem();
  // });

  runApp(SpotTradingApp(themeManager: themeManager));
}
```

**Resultado esperado:**
- ✅ App inicia sin depender de Firebase
- ✅ Si funciona → El problema era Firebase
- ❌ Si sigue en blanco → El problema es otro

---

### **SOLUCIÓN 2: Agregar try-catch y logging** ⭐⭐⭐⭐

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🔥 Iniciando Firebase...');
    await Firebase.initializeApp(
      options: FirebaseConfig.currentPlatform,
    );
    print('✅ Firebase inicializado');
  } catch (e) {
    print('❌ Error Firebase: $e');
  }

  try {
    print('🔧 Configurando ServiceLocator...');
    await ServiceLocator.setup();
    print('✅ ServiceLocator configurado');
  } catch (e) {
    print('❌ Error ServiceLocator: $e');
  }

  try {
    print('🔔 Inicializando NotificationService...');
    await NotificationService.initialize();
    print('✅ NotificationService inicializado');
  } catch (e) {
    print('❌ Error NotificationService: $e');
  }

  print('🚀 Lanzando app...');
  runApp(SpotTradingApp(themeManager: themeManager));
}
```

**Resultado esperado:**
- ✅ Ver en logs dónde exactamente falla
- ✅ Identificar la causa raíz

---

### **SOLUCIÓN 3: Agregar timeout a inicializaciones** ⭐⭐⭐

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Timeout de 5 segundos para Firebase
    await Firebase.initializeApp(
      options: FirebaseConfig.currentPlatform,
    ).timeout(const Duration(seconds: 5));
  } catch (e) {
    print('Firebase failed or timed out: $e');
  }

  try {
    await NotificationService.initialize()
      .timeout(const Duration(seconds: 5));
  } catch (e) {
    print('NotificationService failed or timed out: $e');
  }

  runApp(SpotTradingApp(themeManager: themeManager));
}
```

---

### **SOLUCIÓN 4: Widget de error/loading inicial** ⭐⭐⭐⭐

Agregar widget que muestre estado mientras inicializa:

```dart
class SpotTradingApp extends StatefulWidget {
  @override
  State<SpotTradingApp> createState() => _SpotTradingAppState();
}

class _SpotTradingAppState extends State<SpotTradingApp> {
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Inicializaciones aquí
      await ServiceLocator.setup();
      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error: $_errorMessage'),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MultiProvider(
      // ... resto del código
    );
  }
}
```

---

## 🔧 **COMANDOS PARA DEBUGGING:**

### **Ver logs completos:**
```bash
cd ~/dev_projects/spot
export PATH="/Users/richardgarcia/flutter/bin:$PATH"

# Ver logs en tiempo real
flutter run -d 00008110-0008145A36B9401E --verbose

# Buscar errores específicos
flutter run -d 00008110-0008145A36B9401E 2>&1 | grep -i "error\|exception\|failed"
```

### **Limpiar y recompilar:**
```bash
cd ~/dev_projects/spot
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run -d 00008110-0008145A36B9401E
```

### **Ver logs del dispositivo (consola nativa):**
En Xcode:
1. Window → Devices and Simulators
2. Seleccionar "Ricdev"
3. Ver consola en tiempo real

---

## 📋 **CHECKLIST DE DEBUGGING:**

- [ ] Verificar que ServiceLocator.setup() completa exitosamente
- [ ] Verificar que CryptoBloc se crea correctamente
- [ ] Revisar logs de Firebase initialization
- [ ] Revisar logs de NotificationService
- [ ] Verificar que SpotMainPage se renderiza
- [ ] Verificar estado inicial de BLoC
- [ ] Revisar si hay errores en consola de Xcode
- [ ] Probar con Firebase completamente deshabilitado

---

## 📊 **INFORMACIÓN DEL ENTORNO:**

```
Device: iPhone "Ricdev" (00008110-0008145A36B9401E)
iOS: 26.0.1
Flutter: 3.35.7
Xcode: 16.0.1
Build: Debug-iphoneos
```

---

## 🎯 **PRÓXIMOS PASOS:**

1. **INMEDIATO:** Implementar SOLUCIÓN 1 (deshabilitar Firebase)
2. **Si funciona:** El problema es Firebase dummy → Configurar Firebase real o dejar deshabilitado
3. **Si NO funciona:** Implementar SOLUCIÓN 2 (logging) para identificar causa
4. **Una vez identificado:** Aplicar fix específico

---

## 📝 **NOTAS ADICIONALES:**

### **¿Por qué Firebase está deshabilitado?**
Según el comentario en `firebase_config.dart`:
> "Firebase está deshabilitado temporalmente debido a incompatibilidad con Xcode 26.x"

**Opciones:**
1. Dejar Firebase deshabilitado y quitar dependencias
2. Configurar Firebase correctamente con GoogleService-Info.plist real
3. Actualizar Firebase a versión compatible con Xcode 26.x

### **Archivos clave:**
```
lib/main.dart                                    ← Inicialización
lib/src/core/config/firebase_config.dart         ← Config dummy
lib/src/core/di/service_locator.dart            ← DI container
lib/src/infrastructure/services/notification_service.dart
lib/src/presentation/pages/spot_main_page.dart  ← UI principal
ios/Runner/GoogleService-Info.plist             ← Config Firebase
```

---

## 🆘 **SI NADA FUNCIONA:**

### **Plan B: Rollback a versión funcionando**

```bash
cd ~/dev_projects/spot
git log --oneline -n 10  # Ver commits recientes
git checkout [commit-hash-que-funcionaba]
flutter run
```

### **Plan C: Crear proyecto nuevo limpio**

```bash
flutter create spot_test
# Copiar solo lib/ y assets/
# Verificar si funciona sin Firebase
```

---

**Última actualización:** 24 de Octubre de 2025, 10:45  
**Estado:** En investigación - App compila pero pantalla blanca  
**Ubicación:** `~/dev_projects/PROBLEMA_PANTALLA_BLANCA_SPOT.md`

---

## 🔗 **REFERENCIAS:**

- Issue similar: https://github.com/flutter/flutter/issues/95099
- Firebase initialization: https://firebase.flutter.dev/docs/overview
- BLoC debugging: https://bloclibrary.dev/#/coreconcepts?id=bloc-observer

---

**Para el próximo agente:** Lee este archivo primero antes de intentar arreglar el problema. Contiene TODO el contexto y las soluciones propuestas.
