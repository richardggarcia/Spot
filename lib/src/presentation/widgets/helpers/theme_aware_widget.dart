import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../managers/theme_manager.dart';

/// Widget helper para acceso consistente al tema en toda la aplicación
/// Resuelve problemas de transparencia y rebuild al cambiar de tema
class ThemeAwareWidget extends StatelessWidget {
  const ThemeAwareWidget({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, bool isDark, ThemeManager themeManager) builder;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return builder(context, themeManager.isDarkMode, themeManager);
      },
    );
  }
}

/// Extension para facilitar acceso al tema desde cualquier context
extension ThemeContext on BuildContext {
  /// Acceso directo al ThemeManager
  ThemeManager get themeManager {
    final manager = Provider.of<ThemeManager>(this, listen: false);
    return manager;
  }

  /// Acceso directo al estado isDark (sin listener)
  bool get isDark => themeManager.isDarkMode;

  /// Acceso directo al estado isDark (con listener)
  bool get isDarkListen => Provider.of<ThemeManager>(this, listen: true).isDarkMode;

  /// Obtener colores de acuerdo al tema actual
  Color getThemedColor(Color darkColor, Color lightColor) {
    return isDark ? darkColor : lightColor;
  }
}