# Changelog

All notable changes to the Spot project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Weekly and monthly trend analysis
- Historical risk assessment (6-month drawdown)
- Advanced charting with interactive graphs
- Multiple exchange integrations
- Enhanced LLM integration for news analysis
- Performance optimizations

## [1.0.0] - 2025-10-03

### Added
- **Core Architecture**: Hexagonal architecture implementation with clean separation of concerns
- **Price Action Analysis**: Mathematical formulas for Deep Drop and Rebound calculations
- **Real-time Data**: Integration with Aspiradora backend for live cryptocurrency prices
- **Smart Alerts**: Automated buy opportunity detection (drop ≤ -5% AND rebound ≥ +3%)
- **14 Cryptocurrencies**: Support for BTC, ETH, BNB, MNT, BCH, LTC, SOL, KCS, TON, RON, SUI, BGB, XRP, LINK
- **BLoC State Management**: Reactive UI with proper state handling
- **Dependency Injection**: Clean dependency management with GetIt
- **Professional UI**: Card-based interface optimized for quick trading decisions
- **Error Handling**: Robust error management without mock data fallbacks

### Technical Features
- **Domain-Driven Design**: Pure business logic in domain layer
- **Repository Pattern**: Clean data access abstraction
- **Use Cases**: Well-defined application workflows
- **Type Safety**: Full null safety implementation
- **Code Quality**: Zero Flutter analysis issues
- **Comprehensive Documentation**: Inline code documentation and README

### Formulas Implemented
- **Deep Drop**: `(Today's Low / Yesterday's Close) - 1`
- **Rebound Strength**: `(Current Price / Today's Low) - 1`
- **Alert Criteria**: Drop ≤ -5% AND Rebound ≥ +3%
- **Opportunity Scoring**: Severity-based ranking system

### UI Components
- **Crypto List Widget**: Real-time price and metrics display
- **Alerts Widget**: Filtered view of buy opportunities
- **Error Widget**: User-friendly error messaging
- **Loading Widget**: Professional loading states

### Infrastructure
- **Aspiradora Integration**: Primary data source for cryptocurrency prices
- **HTTP Client**: Robust API communication with retry logic
- **Caching System**: Intelligent data caching for performance
- **Logging**: Comprehensive logging for debugging and monitoring

## [0.1.0] - 2025-10-01 (Initial Development)

### Added
- Project initialization with Flutter 3.8+
- Basic project structure and configuration
- Initial domain entities (Crypto, DailyMetrics)
- Core trading calculator service
- Basic UI scaffolding

### Development Setup
- Flutter environment configuration
- Dependency management setup
- Code analysis and linting configuration
- Testing framework preparation

---

## Types of Changes

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes

## Release Process

1. Update version in `pubspec.yaml`
2. Update this CHANGELOG.md
3. Create release tag: `git tag v1.0.0`
4. Build release artifacts: `flutter build apk --release`
5. Create GitHub release with artifacts
6. Update documentation if needed

## Versioning Strategy

- **Major** (X.0.0): Breaking changes, major feature additions
- **Minor** (1.X.0): New features, backwards compatible
- **Patch** (1.0.X): Bug fixes, small improvements

## Contributors

Thanks to all contributors who help make this project better:
- Initial development and architecture design
- Price action formula implementation
- UI/UX design and implementation
- Documentation and testing

---

For more details about each release, see the [GitHub Releases](https://github.com/richardggarcia/spot/releases) page.