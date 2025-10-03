# Contributing to Spot

Thank you for your interest in contributing to Spot! This document provides guidelines for contributing to this open-source price action analysis tool.

## 🎯 Project Vision

Spot aims to democratize price action analysis for cryptocurrency traders by providing:
- Professional-grade mathematical analysis
- Clean, maintainable code architecture
- Educational value for the trading community
- Open-source accessibility for all traders

## 🛠️ Development Setup

### Prerequisites
- Flutter 3.8+ installed
- Dart 3.0+
- Git
- Android Studio or VS Code with Flutter extensions

### Getting Started
1. Fork the repository
2. Clone your fork: `git clone https://github.com/richardggarcia/spot.git`
3. Install dependencies: `flutter pub get`
4. Verify setup: `flutter analyze` (should show zero issues)
5. Run the app: `flutter run`

## 📋 Code Standards

### Architecture Guidelines
- **Maintain Hexagonal Architecture**: Keep domain logic pure and independent
- **Follow SOLID principles**: Single responsibility, open/closed, etc.
- **Use dependency injection**: Register services through GetIt
- **Implement proper error handling**: No silent failures

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comprehensive documentation for public APIs
- Maintain consistent formatting with `dart format`

### Testing Requirements
- Write unit tests for domain logic
- Add widget tests for UI components
- Ensure `flutter test` passes
- Maintain or improve code coverage

## 🔄 Contribution Process

### 1. Choose Your Contribution
- **Bug Fixes**: Check existing issues or report new ones
- **Features**: Discuss in GitHub Discussions before implementing
- **Documentation**: Always welcome improvements
- **Performance**: Optimization and efficiency improvements

### 2. Development Workflow
```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make your changes
# ... code, test, document ...

# Verify quality
flutter analyze
flutter test
dart format lib/

# Commit with clear message
git commit -m "feat: add weekly trend analysis"

# Push and create PR
git push origin feature/your-feature-name
```

### 3. Pull Request Guidelines
- **Clear title**: Describe what the PR does
- **Detailed description**: Explain the problem and solution
- **Screenshots**: For UI changes, include before/after images
- **Tests**: Include relevant test cases
- **Documentation**: Update README or docs if needed

## 🎯 Priority Areas for Contribution

### High Priority
- **Exchange Integrations**: Additional APIs (Binance, Coinbase, etc.)
- **Historical Data Analysis**: Weekly/monthly trend implementation
- **Error Handling**: Improved user experience for API failures
- **Performance Optimization**: Memory usage and speed improvements

### Medium Priority
- **UI/UX Enhancements**: Better visual design and user experience
- **Additional Cryptocurrencies**: Support for more trading pairs
- **Advanced Charting**: Interactive price charts and indicators
- **Mobile Optimizations**: Platform-specific improvements

### Welcome Contributions
- **Documentation**: Code comments, README improvements, tutorials
- **Testing**: Unit tests, widget tests, integration tests
- **Accessibility**: Screen reader support, better contrast ratios
- **Internationalization**: Support for multiple languages

## 🐛 Bug Reports

When reporting bugs, please include:
- **Clear description** of the issue
- **Steps to reproduce** the problem
- **Expected behavior** vs actual behavior
- **Environment details** (Flutter version, device, OS)
- **Screenshots or logs** if applicable

Use this template:
```markdown
**Bug Description**
A clear description of what the bug is.

**To Reproduce**
1. Go to '...'
2. Click on '....'
3. See error

**Expected Behavior**
What should happen instead.

**Screenshots**
If applicable, add screenshots.

**Environment**
- Flutter version: [e.g. 3.8.0]
- Device: [e.g. iPhone 12, Pixel 6]
- OS: [e.g. iOS 16, Android 13]
```

## 💡 Feature Requests

For new features:
1. **Check existing discussions** to avoid duplicates
2. **Describe the use case** clearly
3. **Explain the trading benefit** 
4. **Consider implementation complexity**
5. **Propose API or UI changes** if relevant

## 🔧 Technical Guidelines

### Hexagonal Architecture Layers
```
🎨 Presentation: UI components, BLoC, user interactions
🏛️ Domain: Business logic, entities, use cases (pure Dart)
🔧 Infrastructure: APIs, databases, external services
```

### Domain Layer Rules
- **No Flutter dependencies**: Keep domain logic pure Dart
- **No external API details**: Use abstract interfaces (ports)
- **Business logic only**: Mathematical calculations, trading rules
- **Immutable entities**: Use copyWith for updates

### Testing Strategy
- **Domain**: 100% unit test coverage for business logic
- **Infrastructure**: Mock external dependencies
- **Presentation**: Widget tests for UI components
- **Integration**: End-to-end user workflows

## 📚 Learning Resources

### Price Action Trading
- [Investopedia: Price Action](https://www.investopedia.com/articles/active-trading/110714/introduction-price-action-trading-strategies.asp)
- [TradingView: Price Action Basics](https://www.tradingview.com/ideas/priceaction/)

### Flutter Architecture
- [Clean Architecture in Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern Documentation](https://bloclibrary.dev/)
- [Dependency Injection in Flutter](https://pub.dev/packages/get_it)

### Cryptocurrency APIs
- [CoinGecko API Documentation](https://www.coingecko.com/en/api/documentation)
- [Binance API Documentation](https://binance-docs.github.io/apidocs/)

## 🤝 Community Guidelines

### Code of Conduct
- **Be respectful**: Treat all contributors with kindness and respect
- **Be constructive**: Provide helpful feedback and suggestions
- **Be collaborative**: Work together to improve the project
- **Be inclusive**: Welcome contributors of all skill levels

### Communication
- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Pull Requests**: For code contributions and reviews
- **Email**: For private matters or security issues

## 🏆 Recognition

Contributors will be recognized in:
- **README acknowledgments**: Listed as project contributors
- **Release notes**: Mentioned for significant contributions
- **GitHub contributors graph**: Automatic recognition by GitHub

## 🆘 Getting Help

If you need help:
1. **Check the README**: Most common questions are answered there
2. **Search issues**: Your question might already be answered
3. **GitHub Discussions**: Ask the community
4. **Email maintainers**: For private or urgent matters

## 📝 License

By contributing to Spot, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping make price action analysis accessible to the trading community! 🚀