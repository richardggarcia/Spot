import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Estilos de texto personalizados para la aplicación de trading
/// Utiliza:
/// - Outfit: Encabezados (Moderno, Geométrico)
/// - Inter: Cuerpo (Legible, Limpio)
/// - JetBrains Mono: Datos numéricos/técnicos
class AppTextStyles {
  // Textos de encabezado
  static TextStyle h1 = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextPrimary,
    height: 1.2,
  );

  static TextStyle h2 = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextPrimary,
    height: 1.2,
  );

  static TextStyle h3 = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
    height: 1.3,
  );

  static TextStyle h4 = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
    height: 1.3,
  );

  // Textos de cuerpo
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.darkTextPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.darkTextSecondary,
    height: 1.4,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.darkTextTertiary,
    height: 1.4,
  );

  // Textos para etiquetas y títulos de tarjetas
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.darkTextSecondary,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.darkTextTertiary,
  );

  // Textos para precios y valores numéricos - Monospace
  static TextStyle priceLarge = GoogleFonts.jetBrainsMono(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle priceMedium = GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle priceSmall = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
    letterSpacing: -0.5,
  );

  // Textos para cambios porcentuales
  static TextStyle bullish(BuildContext context) => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBullish,
    letterSpacing: -0.5,
  );

  static TextStyle bearish(BuildContext context) => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBearish,
    letterSpacing: -0.5,
  );

  static TextStyle neutral(BuildContext context) => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.darkNeutral,
    letterSpacing: -0.5,
  );

  // Textos para botones
  static TextStyle button = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static TextStyle buttonSecondary = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.darkAccentPrimary,
    letterSpacing: 0.5,
  );

  // Textos para alertas y notificaciones
  static TextStyle alert = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.darkAlert,
  );

  static TextStyle warning = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.darkWarning,
  );

  // Textos para códigos y símbolos
  static TextStyle code = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.darkAccentPrimary,
  );

  // Textos para estados deshabilitados
  static TextStyle disabled = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.darkTextDisabled,
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
  
  /// Obtiene estilo de precio grande con color del tema
  TextStyle get priceLarge => AppTextStyles.priceLarge.copyWith(
    color: Theme.of(this).textTheme.bodyLarge?.color,
  );
}
