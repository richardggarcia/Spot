import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos de texto personalizados para la aplicación de trading
class AppTextStyles {
  // Textos de encabezado
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    height: 1.3,
  );

  // Textos de cuerpo
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.tertiaryText,
    height: 1.4,
  );

  // Textos para etiquetas y títulos de tarjetas
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.tertiaryText,
  );

  // Textos para precios y valores numéricos
  static const TextStyle priceLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle priceMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static const TextStyle priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // Textos para cambios porcentuales
  static TextStyle bullish(BuildContext context) => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.bullish,
  );

  static TextStyle bearish(BuildContext context) => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.bearish,
  );

  static TextStyle neutral(BuildContext context) => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.neutral,
  );

  // Textos para botones
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryAccent,
  );

  // Textos para alertas y notificaciones
  static const TextStyle alert = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.alert,
  );

  static const TextStyle warning = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.warning,
  );

  // Textos para códigos y símbolos
  static const TextStyle code = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryAccent,
    fontFamily: 'monospace',
  );

  // Textos para estados deshabilitados
  static const TextStyle disabled = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.disabledText,
  );
}

extension TextStylesExtension on BuildContext {
  /// Obtiene el texto de encabezado h1 con el tema actual
  TextStyle get h1 => AppTextStyles.h1.copyWith(
    color: Theme.of(this).textTheme.headlineLarge?.color,
  );

  /// Obtiene el texto de encabezado h2 con el tema actual
  TextStyle get h2 => AppTextStyles.h2.copyWith(
    color: Theme.of(this).textTheme.headlineMedium?.color,
  );

  /// Obtiene el texto de encabezado h3 con el tema actual
  TextStyle get h3 => AppTextStyles.h3.copyWith(
    color: Theme.of(this).textTheme.headlineSmall?.color,
  );

  /// Obtiene el texto de cuerpo grande con el tema actual
  TextStyle get bodyLarge => AppTextStyles.bodyLarge.copyWith(
    color: Theme.of(this).textTheme.bodyLarge?.color,
  );

  /// Obtiene el texto de cuerpo mediano con el tema actual
  TextStyle get bodyMedium => AppTextStyles.bodyMedium.copyWith(
    color: Theme.of(this).textTheme.bodyMedium?.color,
  );

  /// Obtiene el texto de cuerpo pequeño con el tema actual
  TextStyle get bodySmall => AppTextStyles.bodySmall.copyWith(
    color: Theme.of(this).textTheme.bodySmall?.color,
  );
}
