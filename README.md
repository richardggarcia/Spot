# 📊 Spot - Análisis de Price Action

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Hexagonal-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**Herramienta Profesional de Análisis Price Action para Trading de Criptomonedas**

*Desarrollada con Flutter y Arquitectura Hexagonal*

[🚀 Características](#-características) • [📱 Capturas](#-capturas) • [🏗️ Arquitectura](#️-arquitectura) • [⚡ Inicio Rápido](#-inicio-rápido) • [🤝 Contribuir](#-contribuir)

</div>

---

## 🎯 **Descripción del Proyecto**

**Spot** es una aplicación profesional desarrollada en Flutter diseñada para traders de criptomonedas que se enfocan en **Análisis de Price Action**. La app identifica oportunidades de compra durante caídas del mercado utilizando algoritmos matemáticos sofisticados y datos de mercado en tiempo real.

### **Concepto Clave: Trading de Price Action**
El trading de Price Action analiza movimientos puros de precio sin indicadores, enfocándose en:
- **Caídas Profundas**: Máxima caída porcentual desde el cierre anterior al mínimo actual
- **Rebotes**: Fuerza de recuperación desde el mínimo diario al precio actual
- **Alertas de Compra**: Detección automática de oportunidades cuando se cumplen criterios específicos

---

## ✨ **Características**

### 🔬 **Análisis Avanzado de Precios**
- **Análisis de Price Action** en tiempo real para 14 criptomonedas principales
- **Fórmulas matemáticas** para cálculos de Caída Profunda y Rebote
- **Alertas Inteligentes de Compra** cuando caída ≤ -5% Y rebote ≥ +3%
- **Veredictos impulsados por IA** usando integración LLM para contexto del mercado

### 📊 **Métricas Profesionales de Trading**
- **Cálculo de Caída Profunda**: `(Mínimo de Hoy / Cierre de Ayer) - 1`
- **Fuerza de Rebote**: `(Precio Actual / Mínimo de Hoy) - 1`  
- **Puntuación de Oportunidades** con niveles de severidad (Mínima → Severa)
- **Sugerencias de Precios** de entrada y salida con márgenes de seguridad

### 🏗️ **Arquitectura Empresarial**
- **Arquitectura Hexagonal** (patrón Ports & Adapters)
- **Diseño Dirigido por Dominio** con lógica de negocio pura
- **Gestión de Estado BLoC** para UI reactiva
- **Inyección de Dependencias** con localizador de servicios GetIt

### 🎨 **UI/UX Moderna**
- **Interfaz basada en Tarjetas** optimizada para escaneo rápido
- **Alertas con Código de Colores** para reconocimiento visual inmediato
- **Diseño Responsivo** que soporta múltiples tamaños de pantalla
- **Actualizaciones en Tiempo Real** con funcionalidad pull-to-refresh

---

## 📱 **Capturas de Pantalla**

<div align="center">

### Panel Principal
*Análisis de Price Action con alertas en tiempo real*

| Modo Claro | Modo Oscuro | Vista de Alertas |
|------------|-------------|------------------|
| 🖼️ *Próximamente* | 🖼️ *Próximamente* | 🖼️ *Próximamente* |

### Análisis Histórico
*Análisis de tendencias semanales y mensuales*

| Gráficos de Tendencia | Métricas de Riesgo | Línea de Tiempo de Oportunidades |
|-----------------------|--------------------|------------------------------------|
| 🖼️ *Próximamente* | 🖼️ *Próximamente* | 🖼️ *Próximamente* |

</div>

---

## 🏗️ **Architecture**

### **Hexagonal Architecture (Ports & Adapters)**

```
🎨 Presentation Layer
   Flutter UI + BLoC
         ↓
🏛️ Domain Core
   ├── Use Cases
   ├── Entities (Crypto • DailyMetrics)
   ├── Domain Services (TradingCalculator)
   └── 🔌 Ports (Repository Interfaces)
         ↓
🔧 Infrastructure
   ├── Repository Implementation
   ├── 🌐 API Adapter (Aspiradora Integration)
   └── 🤖 LLM Adapter (News Analysis)
```

### **Key Components**

#### **🎯 Domain Layer (Business Logic)**
- **Entities**: `Crypto`, `DailyMetrics` with pure business rules
- **Use Cases**: `GetCryptoData`, `GetAlerts` for application workflows  
- **Services**: `TradingCalculator` with Price Action formulas
- **Ports**: Abstract interfaces for external dependencies

#### **🔧 Infrastructure Layer (External Concerns)**
- **API Adapters**: Integration with Aspiradora backend
- **Repository**: Data access abstraction with caching
- **LLM Integration**: News analysis for market context

#### **🎨 Presentation Layer (UI)**
- **BLoC Pattern**: Reactive state management
- **Widgets**: Reusable UI components
- **Pages**: Screen-level compositions

---

## 🚀 **Criptomonedas Monitoreadas**

La aplicación analiza las siguientes 14 criptomonedas principales:

| Símbolo | Nombre | Enfoque de Mercado |
|---------|--------|-------------------|
| **BTC** | Bitcoin | Oro Digital |
| **ETH** | Ethereum | Contratos Inteligentes |
| **BNB** | Binance Coin | Token de Exchange |
| **MNT** | Mantle | Capa 2 |
| **BCH** | Bitcoin Cash | Pagos |
| **LTC** | Litecoin | Plata del Bitcoin |
| **SOL** | Solana | Alto Rendimiento |
| **KCS** | KuCoin Token | Exchange |
| **TON** | Toncoin | Telegram |
| **RON** | Ronin | Gaming |
| **SUI** | Sui | L1 Nueva Generación |
| **BGB** | Bitget Token | Exchange |
| **XRP** | Ripple | Transfronterizo |
| **LINK** | Chainlink | Red de Oráculos |

---

## ⚡ **Inicio Rápido**

### **Prerrequisitos**
- Flutter 3.8+ instalado
- Dart 3.0+
- Android Studio / VS Code
- Git

### **Instalación**

```bash
# 1. Clonar el repositorio
git clone https://github.com/richardggarcia/spot.git
cd spot

# 2. Instalar dependencias
flutter pub get

# 3. Configurar entorno (opcional)
cp .env.example .env
# Editar .env con tus API keys si es necesario

# 4. Ejecutar la aplicación
flutter run
```

### **Compilar para Producción**

```bash
# APK de Android
flutter build apk --release

# iOS (requiere Xcode)
flutter build ios --release

# Web
flutter build web --release
```

---

## 🧮 **Fórmulas de Trading**

### **Cálculo de Caída Profunda**
```dart
double deepDrop = (todayLow / yesterdayClose) - 1.0;
```
*Mide la máxima caída intradía desde el cierre anterior*

### **Fuerza de Rebote**  
```dart
double rebound = (currentPrice / todayLow) - 1.0;
```
*Mide la fuerza de recuperación desde el mínimo diario*

### **Criterios de Alerta de Compra**
```dart
bool hasBuyAlert = (deepDrop <= -0.05) && (rebound >= 0.03);
```
*Se activa cuando caída ≥ 5% Y rebote ≥ 3%*

### **Puntuación de Oportunidad**
```dart
double score = (dropSeverity.index * 2.0) + reboundStrength.index;
```
*Clasifica oportunidades por severidad y fuerza de recuperación*

---

## 🛠️ **Development**

### **Project Structure**
```
lib/
├── src/
│   ├── core/                   # Shared utilities
│   │   ├── constants/          # App constants
│   │   ├── di/                # Dependency injection
│   │   └── utils/             # Helper functions
│   ├── domain/                # Business logic (Pure Dart)
│   │   ├── entities/          # Core business entities
│   │   ├── repositories/      # Abstract interfaces
│   │   ├── services/          # Domain services
│   │   └── use_cases/         # Application workflows
│   ├── infrastructure/        # External concerns
│   │   ├── datasources/       # API implementations
│   │   └── repositories/      # Repository implementations
│   └── presentation/          # UI Layer
│       ├── bloc/              # State management
│       ├── pages/             # Screens
│       └── widgets/           # UI components
└── main.dart                  # App entry point
```

### **Key Design Patterns**
- **Hexagonal Architecture**: Clean separation of concerns
- **Repository Pattern**: Data access abstraction
- **BLoC Pattern**: Predictable state management
- **Dependency Injection**: Testable and modular code

### **Code Quality**
- **Flutter Analysis**: Zero issues (`flutter analyze`)
- **Type Safety**: Strict null safety enabled
- **Documentation**: Comprehensive inline documentation
- **Testing**: Unit and widget tests (coming soon)

---

## 🔧 **Configuration**

### **API Integration**
The app integrates with Aspiradora backend for real-time price data:

```dart
// Configure API endpoints
static const String aspiradoraBaseUrl = 'http://localhost:3000';
static const String pricesEndpoint = '/api/prices/multiple';
```

### **Error Handling**
Robust error handling without mock data fallbacks:
- **Connection Errors**: Clear user-facing messages
- **API Failures**: "Error de Conexión: Datos de Precio no disponibles"
- **Rate Limiting**: Intelligent retry with exponential backoff

---

## 📊 **Performance Metrics**

- **📱 App Size**: ~15MB (release build)
- **⚡ Launch Time**: <2 seconds on mid-range devices
- **🔄 API Response**: <1 second average
- **💾 Memory Usage**: <100MB typical
- **🔋 Battery**: Optimized for minimal background usage

---

## 🧪 **Testing**

```bash
# Run all tests
flutter test

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Widget tests
flutter test test/widget_test.dart

# Integration tests  
flutter drive --target=test_driver/app.dart
```

---

## 🤝 **Contribuir**

¡Damos la bienvenida a las contribuciones! Este es un proyecto de código abierto diseñado para ayudar a la comunidad de trading de crypto.

### **Cómo Contribuir**

1. **Haz Fork** del repositorio
2. **Crea** una rama de feature (`git checkout -b feature/nueva-caracteristica`)
3. **Haz Commit** de tus cambios (`git commit -m 'Agregar nueva característica'`)
4. **Haz Push** a la rama (`git push origin feature/nueva-caracteristica`)
5. **Abre** un Pull Request

### **Guías de Contribución**
- Sigue las guías de estilo de Dart/Flutter
- Mantén los principios de arquitectura hexagonal
- Agrega tests para nuevas características
- Actualiza la documentación según sea necesario
- Asegúrate de que `flutter analyze` pase sin errores

### **Áreas para Contribuir**
- 🔄 Integraciones adicionales de exchanges (Binance, Coinbase)
- 📊 Capacidades avanzadas de gráficos
- 🤖 Integraciones LLM mejoradas
- 🎨 Mejoras de UI/UX
- 📱 Optimizaciones específicas de plataforma
- 🧪 Expansión de cobertura de tests

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 **Acknowledgments**

- **Flutter Team** for the amazing framework
- **Crypto Community** for inspiration and feedback  
- **Open Source Contributors** who make projects like this possible
- **Price Action Traders** for methodology validation

---

## 📞 **Contacto y Soporte**

- **🐛 Reportes de Bugs**: [GitHub Issues](https://github.com/richardggarcia/spot/issues)
- **💡 Solicitudes de Características**: [GitHub Discussions](https://github.com/richardggarcia/spot/discussions)
- **📧 Email**: contacto@bitsdeve.com
- **🌐 Sitio Web**: [bitsdeve.com](https://www.bitsdeve.com)
- **💼 LinkedIn**: [Richard García](https://www.linkedin.com/in/richardgarciac/)
- **🐙 GitHub**: [@richardggarcia](https://github.com/richardggarcia)

---

<div align="center">

### 🌟 **Star this repository if you found it helpful!**

**Built with ❤️ by [Richard García](https://www.bitsdeve.com) for the crypto trading community**

*Making Price Action Analysis accessible to everyone worldwide*

![Visitor Count](https://visitor-badge.laobi.icu/badge?page_id=richardggarcia.spot)

</div>