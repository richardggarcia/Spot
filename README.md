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
- **Streaming de datos** en vivo via WebSockets de Binance
- **Fórmulas matemáticas** para cálculos de Caída Profunda y Rebote
- **Alertas Inteligentes de Compra** cuando caída ≤ -5% Y rebote ≥ +3%
- **Logos dinámicos** de criptomonedas con enriquecimiento automático
- **Veredictos impulsados por IA** usando integración LLM para contexto del mercado

### 📊 **Métricas Profesionales de Trading**
- **Cálculo de Caída Profunda**: `(Mínimo de Hoy / Cierre de Ayer) - 1`
- **Fuerza de Rebote**: `(Precio Actual / Mínimo de Hoy) - 1`  
- **Puntuación de Oportunidades** con niveles de severidad (Mínima → Severa)
- **Sugerencias de Precios** de entrada y salida con márgenes de seguridad

### 🏗️ **Arquitectura Empresarial**
- **Arquitectura Hexagonal** (patrón Ports & Adapters)
- **Diseño Dirigido por Dominio** con lógica de negocio pura
- **Firebase Integration** para backend escalable y analytics
- **Streaming Data Ports** para datos en tiempo real
- **Gestión de Estado BLoC** para UI reactiva
- **Inyección de Dependencias** con localizador de servicios GetIt
- **Adaptadores especializados** (Binance, CoinGecko, Logo Enrichment)
- **Seguridad avanzada** con manejo seguro de API keys

### 🎨 **UI/UX Moderna**
- **Interfaz basada en Tarjetas** optimizada para escaneo rápido
- **Logos dinámicos** de criptomonedas con carga automática
- **Alertas con Código de Colores** para reconocimiento visual inmediato
- **Diseño Responsivo** que soporta múltiples tamaños de pantalla
- **Actualizaciones en Tiempo Real** via streaming y pull-to-refresh
- **Análisis histórico** con reportes mensuales y tendencias

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
   Flutter UI + BLoC + Streaming Events
         ↓
🏛️ Domain Core
   ├── Use Cases (GetCrypto, GetAlerts, StreamPrices)
   ├── Entities (Crypto • DailyMetrics • RealtimePriceTick)
   ├── Domain Services (TradingCalculator, HistoricalAnalysis)
   └── 🔌 Ports (Repository • StreamingData • LogoEnrichment)
         ↓
🔧 Infrastructure
   ├── Repository Implementation
   ├── 🌐 API Adapters (Binance, CoinGecko, Aspiradora)
   ├── 📡 Streaming Service (Binance WebSockets)
   ├── 🖼️ Logo Enrichment Adapter
   └── 🤖 LLM Adapter (News Analysis)
```

### **Key Components**

#### **🎯 Domain Layer (Business Logic)**
- **Entities**: `Crypto`, `DailyMetrics` with pure business rules
- **Use Cases**: `GetCryptoData`, `GetAlerts` for application workflows  
- **Services**: `TradingCalculator` with Price Action formulas
- **Ports**: Abstract interfaces for external dependencies

#### **🔧 Infrastructure Layer (External Concerns)**
- **API Adapters**: Backend personalizado, Binance, CoinGecko
- **Streaming Service**: Real-time WebSocket connections (Binance)
- **Logo Enrichment**: Dynamic cryptocurrency logo fetching
- **Repository**: Data access abstraction with caching
- **Custom Backend**: https://spot.bitsdeve.com para datos consolidados

#### **🎨 Presentation Layer (UI)**
- **BLoC Pattern**: Reactive state management
- **Widgets**: Reusable UI components
- **Pages**: Screen-level compositions

---

## 📡 **Tecnología de Streaming en Tiempo Real**

### **🔄 WebSocket Integration**
- **Binance WebSockets**: Conexión directa a feeds de trading en vivo
- **RealtimePriceTick**: Entidad de dominio para datos streaming
- **StreamingDataPort**: Interface hexagonal para datos en tiempo real
- **Reconexión automática**: Manejo robusto de desconexiones

### **🏠 Servidor Backend Personalizado**
- **API Backend**: https://spot.bitsdeve.com
- **Firebase Integration**: Analytics, crashlytics y servicios cloud
- **API REST personalizada**: Datos consolidados de múltiples fuentes
- **Alta disponibilidad**: Infraestructura dedicada para el proyecto
- **Arquitectura escalable**: Preparado para crecimiento futuro

### **🔥 Firebase Services**
- **Firebase Analytics**: Tracking de uso y comportamiento de usuarios
- **Crashlytics**: Monitoreo automático de errores en producción
- **Cloud Services**: Infraestructura backend escalable y confiable
- **Configuración segura**: API keys protegidas del repositorio público
- **Setup automatizado**: Documentación completa en `FIREBASE_SETUP.md`

### **🖼️ Enriquecimiento Dinámico de Logos**
- **LogoEnrichmentAdapter**: Obtención automática de logos de CoinGecko
- **Caching inteligente**: Logos se cargan una vez y se reutilizan
- **Fallback graceful**: UI funciona perfectamente sin logos
- **Actualización async**: No bloquea la carga de precios

### **📊 Análisis Histórico Avanzado**
- **HistoricalAnalysisService**: Servicios de dominio para tendencias
- **MonthlyReport**: Entidades para reportes mensuales
- **Métricas de riesgo**: Análisis de volatilidad y drawdown
- **Patrones temporales**: Identificación de oportunidades por períodos

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
- Cuenta de Firebase (opcional, para analytics y crashlytics)

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
The app integrates with multiple data sources for comprehensive market coverage:

```dart
// Backend personalizado para el proyecto
static const String spotApiBaseUrl = 'https://spot.bitsdeve.com';
static const String pricesEndpoint = '/api/prices';

// Binance WebSocket para streaming
static const String binanceWsUrl = 'wss://stream.binance.com:9443/ws';

// CoinGecko para logos y datos adicionales
static const String coinGeckoBaseUrl = 'https://api.coingecko.com/api/v3';
```

### **Error Handling**
Robust error handling with multiple fallback sources:
- **Primary Source**: Servidor propio (https://spot.bitsdeve.com)
- **Secondary Sources**: Binance API y CoinGecko como respaldo
- **Connection Errors**: Mensajes claros al usuario
- **Rate Limiting**: Retry inteligente con backoff exponencial
- **Failover automático**: Cambio automático entre fuentes de datos

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